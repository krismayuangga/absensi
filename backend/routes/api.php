<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\LeaveController;
use App\Http\Controllers\Api\KpiController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\DebugKpiController;
use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\ProfileController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check route
Route::get('health', function () {
    return response()->json([
        'success' => true,
        'message' => 'API is working',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});

// Debug routes (no authentication required) - REMOVE IN PRODUCTION
Route::prefix('debug')->group(function () {
    Route::get('kpi/stats', [DebugKpiController::class, 'debugStats']);
    Route::post('kpi/visit/log', [DebugKpiController::class, 'debugLogVisit']);
    Route::get('kpi/visits', [DebugKpiController::class, 'debugGetVisits']);
    
    // Test attendance without auth
    Route::get('attendance/today', function () {
        return response()->json([
            'success' => true,
            'message' => 'Debug attendance data',
            'data' => [
                'id' => 1,
                'date' => now()->format('Y-m-d'),
                'clock_in_time' => '08:30:00',
                'clock_out_time' => null,
                'work_type' => 'wfh',
                'has_clocked_in' => true,
                'has_clocked_out' => false,
                'working_hours' => 0,
                'location' => 'Jakarta',
            ]
        ]);
    });
    
    // Test notifications endpoint
    Route::get('notifications', function () {
        return response()->json([
            'success' => true,
            'message' => 'Test notifications from Laravel API',
            'data' => [
                [
                    'id' => 1,
                    'type' => 'reminder',
                    'title' => 'Follow-up Real API',
                    'message' => 'Ini notifikasi REAL dari Laravel Backend!',
                    'timestamp' => now()->toISOString(),
                    'is_read' => false,
                    'priority' => 'high',
                    'action_data' => [
                        'client_name' => 'PT Real Client',
                        'visit_id' => 'real_123'
                    ]
                ],
                [
                    'id' => 2,
                    'type' => 'target',
                    'title' => 'API Connection Success',
                    'message' => 'Selamat! Koneksi ke Laravel API berhasil',
                    'timestamp' => now()->subHours(1)->toISOString(),
                    'is_read' => false,
                    'priority' => 'medium'
                ]
            ]
        ]);
    });
    
    // Real database notifications endpoint (for testing without auth)
    Route::get('notifications/real', function () {
        $notifications = \App\Models\Notification::orderBy('created_at', 'desc')
                                               ->limit(10)
                                               ->get();
        
        return response()->json([
            'success' => true,
            'message' => 'Real notifications from database',
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
                    'user_id' => $notification->user_id,
                ];
            })
        ]);
    });
});

// Authentication routes
Route::prefix('v1/auth')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->name('login');
    Route::post('refresh', [AuthController::class, 'refresh']);
});

// Protected routes (require authentication)
Route::middleware('auth:api')->prefix('v1')->group(function () {
    
    // Auth routes (authenticated)
    Route::prefix('auth')->group(function () {
        Route::get('profile', [AuthController::class, 'profile']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
        Route::post('change-password', [AuthController::class, 'changePassword']);
        Route::post('logout', [AuthController::class, 'logout']);
    });

    // Profile routes
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'getUserProfile']);
        Route::put('/', [ProfileController::class, 'updateProfile']);
        Route::post('change-password', [ProfileController::class, 'changePassword']);
        Route::post('upload-image', [ProfileController::class, 'uploadProfileImage']);
    });

        // Attendance routes
        Route::prefix('attendance')->group(function () {
            Route::get('today', [AttendanceController::class, 'getTodayAttendance']);
            Route::post('clock-in', [AttendanceController::class, 'clockIn']);
            Route::post('clock-out', [AttendanceController::class, 'clockOut']);
            Route::get('history', [AttendanceController::class, 'getAttendanceHistory']);
            Route::get('stats', [AttendanceController::class, 'getAttendanceStats']);
            Route::post('recalculate', [AttendanceController::class, 'recalculateWorkingHours']);
        });

        // Leave routes
        Route::prefix('leaves')->group(function () {
            Route::get('balance', [LeaveController::class, 'getLeaveBalance']);
            Route::post('submit', [LeaveController::class, 'submitLeaveRequest']);
            Route::get('history', [LeaveController::class, 'getLeaveHistory']);
            Route::put('cancel/{id}', [LeaveController::class, 'cancelLeaveRequest']);
        });

        // KPI routes
        Route::prefix('kpi')->group(function () {
            Route::get('stats', [KpiController::class, 'getStats']);
            Route::post('visit/log', [KpiController::class, 'logVisit']);
            Route::put('visit/{visitId}/result', [KpiController::class, 'updateResult']);
            Route::get('visits/history', [KpiController::class, 'getHistory']);
            Route::get('visits/pending', [KpiController::class, 'getPendingVisits']);
        });

        // Notification routes
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::post('/', [NotificationController::class, 'store']);
            Route::patch('{id}/read', [NotificationController::class, 'markAsRead']);
            Route::patch('mark-all-read', [NotificationController::class, 'markAllAsRead']);
            Route::delete('{id}', [NotificationController::class, 'destroy']);
            Route::post('generate-smart', [NotificationController::class, 'generateSmartNotifications']);
            Route::post('bulk-send', [NotificationController::class, 'bulkSend']);
            Route::get('stats', [NotificationController::class, 'getStats']);
        });

        // Info & Media routes
        Route::prefix('info-media')->group(function () {
            Route::prefix('announcements')->group(function () {
                Route::get('/', [AnnouncementController::class, 'index']);
                Route::get('categories', [AnnouncementController::class, 'getCategories']);
                Route::get('{announcement}', [AnnouncementController::class, 'show']);
                Route::post('{announcement}/like', [AnnouncementController::class, 'toggleLike']);
                Route::post('{announcement}/comments', [AnnouncementController::class, 'addComment']);
            });
            
            Route::prefix('comments')->group(function () {
                Route::post('{comment}/like', [AnnouncementController::class, 'toggleCommentLike']);
            });

            Route::prefix('media')->group(function () {
                Route::get('/', [MediaController::class, 'index']);
                Route::get('categories', [MediaController::class, 'getCategories']);
                Route::get('{media}', [MediaController::class, 'show']);
                Route::get('{media}/download', [MediaController::class, 'download']);
            });
        });

        // Admin Dashboard routes (for admin role only)
        Route::prefix('admin')->middleware('role:admin')->group(function () {
            Route::get('kpi/overview', [AdminDashboardController::class, 'getKpiOverview']);
            Route::get('kpi/users', [AdminDashboardController::class, 'getAllUsersKpi']);
            Route::get('kpi/users/{userId}/visits', [AdminDashboardController::class, 'getUserVisits']);
            Route::get('kpi/top-performers', [AdminDashboardController::class, 'getTopPerformers']);
            Route::get('kpi/export', [AdminDashboardController::class, 'exportKpiData']);
            
            // Admin management routes
            Route::get('dashboard/stats', [AdminController::class, 'getDashboardStats']);
            Route::get('dashboard/attendance-detail', [AdminController::class, 'getDetailedAttendanceReport']);
            Route::get('employees', [AdminController::class, 'getEmployees']);
            Route::get('employees/{id}', [AdminController::class, 'getEmployee']);
            Route::post('employees', [AdminController::class, 'createEmployee']);
            Route::put('employees/{id}', [AdminController::class, 'updateEmployee']);
            Route::delete('employees/{id}', [AdminController::class, 'deleteEmployee']);
            Route::get('attendance', [AdminController::class, 'getAttendanceRecords']);
            Route::get('leaves', [AdminController::class, 'getLeaveRequests']);
            Route::put('leaves/{id}/status', [AdminController::class, 'updateLeaveStatus']);
            Route::get('master-data', [AdminController::class, 'getMasterData']);
            
            // Admin Info & Media management
            Route::prefix('info-media')->group(function () {
                Route::post('announcements', [AnnouncementController::class, 'store']);
                Route::put('announcements/{announcement}', [AnnouncementController::class, 'update']);
                Route::delete('announcements/{announcement}', [AnnouncementController::class, 'destroy']);
                
                Route::post('media', [MediaController::class, 'store']);
                Route::put('media/{media}', [MediaController::class, 'update']);
                Route::delete('media/{media}', [MediaController::class, 'destroy']);
            });
        });
});

// Public Info & Media routes (no auth required for reading)
Route::prefix('info-media')->group(function () {
    Route::get('announcements', [AnnouncementController::class, 'index']);
    Route::get('announcements/{announcement}', [AnnouncementController::class, 'show']);
    Route::get('media', [MediaController::class, 'index']);
    Route::get('media/{media}', [MediaController::class, 'show']);
});

// Admin roles route (no auth for testing)
Route::get('admin-roles', function () {
    try {
        $roles = \DB::table('admin_roles')->get();
        return response()->json([
            'success' => true,
            'data' => $roles
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Error fetching admin roles: ' . $e->getMessage()
        ], 500);
    }
});
