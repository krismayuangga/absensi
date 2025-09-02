<?php

namespace App\Http\Controllers;

use App\Models\Leave;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class LeaveController extends Controller
{
    /**
     * Get user leave balance
     */
    public function getLeaveBalance(Request $request)
    {
        try {
            $user = Auth::user();
            $year = $request->get('year', Carbon::now()->year);
            
            $balance = Leave::getLeaveBalance($user->id, $year);
            $usedLeave = Leave::where('user_id', $user->id)
                ->where('type', 'annual')
                ->where('status', 'approved')
                ->whereYear('start_date', $year)
                ->sum('total_days');
            
            return response()->json([
                'success' => true,
                'data' => [
                    'year' => $year,
                    'total_annual_leave' => 12,
                    'used_leave' => $usedLeave,
                    'remaining_leave' => $balance,
                    'pending_requests' => Leave::where('user_id', $user->id)
                        ->where('status', 'pending')
                        ->whereYear('start_date', $year)
                        ->count()
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get leave balance: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Submit leave request
     */
    public function submitLeaveRequest(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'type' => 'required|in:sick,annual,personal,emergency,maternity,paternity',
                'start_date' => 'required|date|after_or_equal:today',
                'end_date' => 'required|date|after_or_equal:start_date',
                'reason' => 'required|string|min:10',
                'is_half_day' => 'boolean',
                'half_day_period' => 'nullable|in:morning,afternoon',
                'emergency_contact' => 'nullable|string',
                'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            $startDate = Carbon::parse($request->start_date);
            $endDate = Carbon::parse($request->end_date);
            $isHalfDay = $request->boolean('is_half_day');

            // Calculate total days
            if ($isHalfDay) {
                $totalDays = 0.5;
                $endDate = $startDate; // Half day means same date
            } else {
                $totalDays = $startDate->diffInDays($endDate) + 1;
            }

            // Handle file attachment
            $attachmentPath = null;
            if ($request->hasFile('attachment')) {
                $file = $request->file('attachment');
                $filename = 'leave_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
                $attachmentPath = $file->storeAs('leaves/attachments', $filename, 'public');
            }

            // Create leave request
            $leave = Leave::create([
                'user_id' => $user->id,
                'employee_id' => $user->employee_id,
                'type' => $request->type,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'total_days' => $totalDays,
                'reason' => $request->reason,
                'attachment' => $attachmentPath,
                'emergency_contact' => $request->emergency_contact,
                'is_half_day' => $isHalfDay,
                'half_day_period' => $isHalfDay ? $request->half_day_period : null,
                'status' => 'pending'
            ]);

            return response()->json([
                'success' => true,
                'data' => $leave,
                'message' => 'Pengajuan cuti berhasil disubmit'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to submit leave request: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get leave history
     */
    public function getLeaveHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $page = $request->get('page', 1);
            $limit = $request->get('limit', 10);

            $leaves = Leave::where('user_id', $user->id)
                ->with(['approver:id,name'])
                ->orderBy('created_at', 'desc')
                ->paginate($limit, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'data' => $leaves
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get leave history: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cancel leave request
     */
    public function cancelLeaveRequest($id)
    {
        try {
            $user = Auth::user();
            $leave = Leave::where('user_id', $user->id)->findOrFail($id);

            if (!$leave->canBeCancelled()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Leave request cannot be cancelled'
                ], 400);
            }

            $leave->update(['status' => 'cancelled']);

            return response()->json([
                'success' => true,
                'message' => 'Leave request cancelled successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel leave request: ' . $e->getMessage()
            ], 500);
        }
    }
}
