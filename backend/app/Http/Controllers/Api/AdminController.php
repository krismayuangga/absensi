<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use App\Models\Company;
use App\Models\Department;
use App\Models\Position;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api');
        // Role middleware sudah diterapkan di routes, tidak perlu di controller
    }

    /**
     * Get dashboard statistics
     */
    public function getDashboardStats()
    {
        try {
            $today = Carbon::today();
            $thisMonth = Carbon::now()->startOfMonth();
            
            // Total employees
            $totalEmployees = User::where('role', 'employee')->count();
            
            // Today's attendance
            $todayAttendance = Attendance::whereDate('date', $today)->count();
            $attendancePercentage = $totalEmployees > 0 ? round(($todayAttendance / $totalEmployees) * 100, 1) : 0;
            
            // Pending leaves
            $pendingLeaves = Leave::where('status', 'pending')->count();
            
            // This month's attendance average
            $monthlyAttendance = Attendance::whereMonth('date', $thisMonth->month)
                ->whereYear('date', $thisMonth->year)
                ->selectRaw('DATE(date) as attendance_date, COUNT(DISTINCT user_id) as unique_attendees')
                ->groupBy('attendance_date')
                ->get();
                
            $monthlyAverage = $monthlyAttendance->count() > 0 
                ? round($monthlyAttendance->avg('unique_attendees'), 1) 
                : 0;

            // Recent activities (last 10 attendance records)
            $recentActivities = Attendance::with(['user:id,name,employee_code'])
                ->latest('clock_in')
                ->limit(10)
                ->get()
                ->map(function ($attendance) {
                    return [
                        'id' => $attendance->id,
                        'employee_name' => $attendance->user->name,
                        'employee_code' => $attendance->user->employee_code,
                        'action' => 'clock_in',
                        'time' => $attendance->clock_in,
                        'date' => $attendance->date,
                        'status' => $attendance->status,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => [
                    'stats' => [
                        'total_employees' => $totalEmployees,
                        'today_attendance' => $todayAttendance,
                        'attendance_percentage' => $attendancePercentage,
                        'pending_leaves' => $pendingLeaves,
                        'monthly_average' => $monthlyAverage,
                    ],
                    'recent_activities' => $recentActivities,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving dashboard stats: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all employees with pagination
     */
    public function getEmployees(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 15);
            $search = $request->get('search');
            
            $query = User::where('role', 'employee')
                ->with(['company:id,name', 'department:id,name', 'position:id,name']);
                
            if ($search) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('employee_code', 'like', "%{$search}%");
                });
            }
            
            $employees = $query->latest()->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $employees,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving employees: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create new employee
     */
    public function createEmployee(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'phone' => 'nullable|string|max:20',
                'employee_code' => 'required|string|unique:users,employee_code',
                'company_id' => 'required|exists:companies,id',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'hire_date' => 'required|date',
                'salary' => 'nullable|numeric|min:0',
                'password' => 'required|string|min:6',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $employee = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'employee_code' => $request->employee_code,
                'company_id' => $request->company_id,
                'department_id' => $request->department_id,
                'position_id' => $request->position_id,
                'hire_date' => $request->hire_date,
                'salary' => $request->salary,
                'role' => 'employee',
                'status' => 'active',
                'password' => Hash::make($request->password),
            ]);

            $employee->load(['company:id,name', 'department:id,name', 'position:id,name']);

            return response()->json([
                'success' => true,
                'message' => 'Employee created successfully',
                'data' => $employee,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error creating employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update employee
     */
    public function updateEmployee(Request $request, $id)
    {
        try {
            $employee = User::where('role', 'employee')->findOrFail($id);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email,' . $id,
                'phone' => 'nullable|string|max:20',
                'employee_code' => 'required|string|unique:users,employee_code,' . $id,
                'company_id' => 'required|exists:companies,id',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'hire_date' => 'required|date',
                'salary' => 'nullable|numeric|min:0',
                'status' => 'required|in:active,inactive',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $employee->update($request->only([
                'name', 'email', 'phone', 'employee_code', 'company_id',
                'department_id', 'position_id', 'hire_date', 'salary', 'status'
            ]));

            $employee->load(['company:id,name', 'department:id,name', 'position:id,name']);

            return response()->json([
                'success' => true,
                'message' => 'Employee updated successfully',
                'data' => $employee,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete employee
     */
    public function deleteEmployee($id)
    {
        try {
            $employee = User::where('role', 'employee')->findOrFail($id);
            $employee->delete();

            return response()->json([
                'success' => true,
                'message' => 'Employee deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error deleting employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get attendance records with filtering
     */
    public function getAttendanceRecords(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 15);
            $date = $request->get('date');
            $employeeId = $request->get('employee_id');
            $status = $request->get('status');
            
            $query = Attendance::with(['user:id,name,employee_code']);
            
            if ($date) {
                $query->whereDate('date', $date);
            }
            
            if ($employeeId) {
                $query->where('user_id', $employeeId);
            }
            
            if ($status) {
                $query->where('status', $status);
            }
            
            $attendances = $query->latest('date')->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $attendances,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving attendance records: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get leave requests with filtering
     */
    public function getLeaveRequests(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 15);
            $status = $request->get('status');
            $employeeId = $request->get('employee_id');
            
            $query = Leave::with(['user:id,name,employee_code']);
            
            if ($status) {
                $query->where('status', $status);
            }
            
            if ($employeeId) {
                $query->where('user_id', $employeeId);
            }
            
            $leaves = $query->latest('created_at')->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $leaves,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving leave requests: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Approve/Reject leave request
     */
    public function updateLeaveStatus(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'status' => 'required|in:approved,rejected',
                'admin_notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $leave = Leave::findOrFail($id);
            
            $leave->update([
                'status' => $request->status,
                'admin_notes' => $request->admin_notes,
                'approved_by' => auth()->id(),
                'approved_at' => now(),
            ]);

            $leave->load(['user:id,name,employee_code']);

            return response()->json([
                'success' => true,
                'message' => 'Leave request updated successfully',
                'data' => $leave,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating leave request: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get companies, departments, and positions for dropdowns
     */
    public function getMasterData()
    {
        try {
            $companies = Company::select('id', 'name')->where('is_active', true)->get();
            $departments = Department::select('id', 'name')->where('is_active', true)->get();
            $positions = Position::select('id', 'name')->where('is_active', true)->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'companies' => $companies,
                    'departments' => $departments,
                    'positions' => $positions,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving master data: ' . $e->getMessage(),
            ], 500);
        }
    }
}
