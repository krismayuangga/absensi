<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KpiVisit;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class NotificationController extends Controller
{
    // Get notifications for current user
    public function index(Request $request)
    {
        try {
            $query = Notification::where('user_id', auth()->id())
                                ->orderBy('created_at', 'desc');

            // Filter by type
            if ($request->has('type')) {
                $query->where('type', $request->type);
            }

            // Filter unread only
            if ($request->boolean('unread')) {
                $query->where('is_read', false);
            }

            $notifications = $query->get();

            return response()->json([
                'success' => true,
                'data' => $notifications->map(function ($notification) {
                    return [
                        'id' => $notification->id,
                        'type' => $notification->type,
                        'title' => $notification->title,
                        'message' => $notification->message,
                        'timestamp' => $notification->created_at->toISOString(),
                        'is_read' => $notification->is_read,
                        'priority' => $notification->priority,
                        'action_data' => $notification->action_data,
                    ];
                })
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch notifications'
            ], 500);
        }
    }

    // Create notification (for admin dashboard)
    public function store(Request $request)
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'type' => 'required|string',
                'title' => 'required|string',
                'message' => 'required|string',
                'priority' => 'in:low,medium,high',
                'action_data' => 'nullable|array',
            ]);

            $notification = Notification::create([
                'user_id' => $request->user_id,
                'type' => $request->type,
                'title' => $request->title,
                'message' => $request->message,
                'priority' => $request->priority ?? 'medium',
                'action_data' => $request->action_data,
                'is_read' => false,
            ]);

            return response()->json([
                'success' => true,
                'data' => $notification,
                'message' => 'Notification created successfully'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create notification'
            ], 500);
        }
    }

    // Mark notification as read
    public function markAsRead($id)
    {
        try {
            $notification = Notification::where('id', $id)
                                      ->where('user_id', auth()->id())
                                      ->first();

            if (!$notification) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification not found'
                ], 404);
            }

            $notification->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => 'Notification marked as read'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark notification as read'
            ], 500);
        }
    }

    // Mark all notifications as read
    public function markAllAsRead()
    {
        try {
            Notification::where('user_id', auth()->id())
                       ->where('is_read', false)
                       ->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => 'All notifications marked as read'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark all notifications as read'
            ], 500);
        }
    }

    // Delete notification
    public function destroy($id)
    {
        try {
            $notification = Notification::where('id', $id)
                                      ->where('user_id', auth()->id())
                                      ->first();

            if (!$notification) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification not found'
                ], 404);
            }

            $notification->delete();

            return response()->json([
                'success' => true,
                'message' => 'Notification deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete notification'
            ], 500);
        }
    }

    // Generate smart notifications based on KPI data
    public function generateSmartNotifications()
    {
        try {
            $users = User::where('role', 'employee')->get();
            $notifications = [];

            foreach ($users as $user) {
                // Check pending follow-ups
                $pendingVisits = KpiVisit::where('user_id', $user->id)
                                        ->where('status', 'pending')
                                        ->where('created_at', '<=', Carbon::now()->subDays(3))
                                        ->get();

                foreach ($pendingVisits as $visit) {
                    $daysSince = Carbon::now()->diffInDays($visit->created_at);
                    
                    $notification = Notification::create([
                        'user_id' => $user->id,
                        'type' => 'reminder',
                        'title' => 'Follow-up Reminder',
                        'message' => "Follow-up diperlukan untuk {$visit->client_name} ({$daysSince} hari yang lalu)",
                        'priority' => $daysSince >= 7 ? 'high' : 'medium',
                        'action_data' => [
                            'visit_id' => $visit->id,
                            'client_name' => $visit->client_name,
                        ],
                        'is_read' => false,
                    ]);

                    $notifications[] = $notification;
                }

                // Check target achievements
                $monthlyVisits = KpiVisit::where('user_id', $user->id)
                                        ->whereMonth('created_at', Carbon::now()->month)
                                        ->count();

                $monthlyTarget = 30; // Could be from user profile/settings
                $progress = ($monthlyVisits / $monthlyTarget) * 100;

                // Achievement milestones
                if ($progress >= 100 && $progress < 105) {
                    $notification = Notification::create([
                        'user_id' => $user->id,
                        'type' => 'target',
                        'title' => 'Target Tercapai! 🎉',
                        'message' => 'Selamat! Anda telah mencapai 100% target bulanan',
                        'priority' => 'high',
                        'is_read' => false,
                    ]);
                    $notifications[] = $notification;
                } elseif ($progress >= 75 && $progress < 80) {
                    $notification = Notification::create([
                        'user_id' => $user->id,
                        'type' => 'target',
                        'title' => 'Mendekati Target',
                        'message' => "Hebat! Anda telah mencapai " . round($progress) . "% target bulanan",
                        'priority' => 'medium',
                        'is_read' => false,
                    ]);
                    $notifications[] = $notification;
                }
            }

            return response()->json([
                'success' => true,
                'notifications' => $notifications,
                'message' => count($notifications) . ' smart notifications generated'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate smart notifications'
            ], 500);
        }
    }

    // Bulk send notifications to multiple users (for admin)
    public function bulkSend(Request $request)
    {
        try {
            $request->validate([
                'user_ids' => 'required|array',
                'user_ids.*' => 'exists:users,id',
                'type' => 'required|string',
                'title' => 'required|string',
                'message' => 'required|string',
                'priority' => 'in:low,medium,high',
            ]);

            $notifications = [];

            foreach ($request->user_ids as $userId) {
                $notification = Notification::create([
                    'user_id' => $userId,
                    'type' => $request->type,
                    'title' => $request->title,
                    'message' => $request->message,
                    'priority' => $request->priority ?? 'medium',
                    'is_read' => false,
                ]);

                $notifications[] = $notification;
            }

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'message' => count($notifications) . ' notifications sent successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send bulk notifications'
            ], 500);
        }
    }

    // Get notification statistics (for admin dashboard)
    public function getStats()
    {
        try {
            $stats = [
                'total_notifications' => Notification::count(),
                'unread_notifications' => Notification::where('is_read', false)->count(),
                'notifications_by_type' => Notification::select('type', DB::raw('count(*) as count'))
                                                     ->groupBy('type')
                                                     ->get(),
                'notifications_by_priority' => Notification::select('priority', DB::raw('count(*) as count'))
                                                          ->groupBy('priority')
                                                          ->get(),
                'recent_notifications' => Notification::with('user:id,name')
                                                    ->orderBy('created_at', 'desc')
                                                    ->limit(10)
                                                    ->get(),
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch notification statistics'
            ], 500);
        }
    }
}
