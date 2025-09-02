<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KpiVisit;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminDashboardController extends Controller
{
    // Get KPI overview for all users
    public function getKpiOverview()
    {
        try {
            $stats = [
                'total_visits' => KpiVisit::count(),
                'total_users' => User::where('role', 'employee')->count(),
                'this_month_visits' => KpiVisit::whereMonth('created_at', Carbon::now()->month)->count(),
                'success_rate' => $this->calculateOverallSuccessRate(),
                'total_potential_value' => KpiVisit::sum('potential_value'),
                'visits_by_status' => KpiVisit::select('status', DB::raw('count(*) as count'))
                                            ->groupBy('status')
                                            ->get(),
                'visits_by_purpose' => KpiVisit::select('purpose', DB::raw('count(*) as count'))
                                             ->groupBy('purpose')
                                             ->get(),
                'daily_visits_trend' => $this->getDailyVisitsTrend(),
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch KPI overview'
            ], 500);
        }
    }

    // Get detailed KPI data for all users
    public function getAllUsersKpi(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 10);
            $sortBy = $request->get('sort_by', 'total_visits');
            $sortOrder = $request->get('sort_order', 'desc');

            $users = User::where('role', 'employee')
                        ->with(['kpiVisits' => function($query) {
                            $query->whereMonth('created_at', Carbon::now()->month);
                        }])
                        ->get()
                        ->map(function ($user) {
                            $monthlyVisits = $user->kpiVisits;
                            $successfulVisits = $monthlyVisits->where('status', 'success')->count();
                            $totalVisits = $monthlyVisits->count();
                            
                            return [
                                'user_id' => $user->id,
                                'name' => $user->name,
                                'email' => $user->email,
                                'total_visits' => $totalVisits,
                                'successful_visits' => $successfulVisits,
                                'success_rate' => $totalVisits > 0 ? round(($successfulVisits / $totalVisits) * 100, 2) : 0,
                                'potential_value' => $monthlyVisits->sum('potential_value'),
                                'last_visit' => $monthlyVisits->max('created_at'),
                                'visits_by_purpose' => $monthlyVisits->groupBy('purpose')->map->count(),
                                'visits_by_status' => $monthlyVisits->groupBy('status')->map->count(),
                            ];
                        })
                        ->sortBy($sortBy, SORT_REGULAR, $sortOrder === 'desc')
                        ->values();

            // Manual pagination
            $currentPage = $request->get('page', 1);
            $offset = ($currentPage - 1) * $perPage;
            $paginatedUsers = $users->slice($offset, $perPage)->values();

            return response()->json([
                'success' => true,
                'data' => $paginatedUsers,
                'pagination' => [
                    'current_page' => $currentPage,
                    'per_page' => $perPage,
                    'total' => $users->count(),
                    'last_page' => ceil($users->count() / $perPage),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch users KPI data'
            ], 500);
        }
    }

    // Get detailed visits for specific user
    public function getUserVisits($userId, Request $request)
    {
        try {
            $user = User::findOrFail($userId);
            
            $query = KpiVisit::where('user_id', $userId)
                            ->orderBy('created_at', 'desc');

            // Filter by date range
            if ($request->has('start_date') && $request->has('end_date')) {
                $query->whereBetween('created_at', [
                    $request->start_date,
                    $request->end_date
                ]);
            }

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filter by purpose
            if ($request->has('purpose')) {
                $query->where('purpose', $request->purpose);
            }

            $visits = $query->paginate($request->get('per_page', 15));

            return response()->json([
                'success' => true,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'data' => $visits->items(),
                'pagination' => [
                    'current_page' => $visits->currentPage(),
                    'per_page' => $visits->perPage(),
                    'total' => $visits->total(),
                    'last_page' => $visits->lastPage(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch user visits'
            ], 500);
        }
    }

    // Get top performers
    public function getTopPerformers(Request $request)
    {
        try {
            $period = $request->get('period', 'month'); // month, week, year
            $limit = $request->get('limit', 10);

            $dateFilter = match($period) {
                'week' => Carbon::now()->startOfWeek(),
                'month' => Carbon::now()->startOfMonth(),
                'year' => Carbon::now()->startOfYear(),
                default => Carbon::now()->startOfMonth(),
            };

            $performers = User::where('role', 'employee')
                            ->withCount(['kpiVisits as total_visits' => function($query) use ($dateFilter) {
                                $query->where('created_at', '>=', $dateFilter);
                            }])
                            ->withCount(['kpiVisits as successful_visits' => function($query) use ($dateFilter) {
                                $query->where('created_at', '>=', $dateFilter)
                                      ->where('status', 'success');
                            }])
                            ->with(['kpiVisits' => function($query) use ($dateFilter) {
                                $query->where('created_at', '>=', $dateFilter);
                            }])
                            ->get()
                            ->map(function($user) {
                                $successRate = $user->total_visits > 0 
                                    ? ($user->successful_visits / $user->total_visits) * 100 
                                    : 0;
                                
                                return [
                                    'user_id' => $user->id,
                                    'name' => $user->name,
                                    'total_visits' => $user->total_visits,
                                    'successful_visits' => $user->successful_visits,
                                    'success_rate' => round($successRate, 2),
                                    'potential_value' => $user->kpiVisits->sum('potential_value'),
                                ];
                            })
                            ->sortByDesc('success_rate')
                            ->take($limit)
                            ->values();

            return response()->json([
                'success' => true,
                'data' => $performers,
                'period' => $period
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch top performers'
            ], 500);
        }
    }

    // Export all KPI data
    public function exportKpiData(Request $request)
    {
        try {
            $format = $request->get('format', 'csv'); // csv, json, excel
            $startDate = $request->get('start_date');
            $endDate = $request->get('end_date');

            $query = KpiVisit::with(['user:id,name,email'])
                            ->orderBy('created_at', 'desc');

            if ($startDate && $endDate) {
                $query->whereBetween('created_at', [$startDate, $endDate]);
            }

            $visits = $query->get();

            $exportData = $visits->map(function($visit) {
                return [
                    'id' => $visit->id,
                    'user_name' => $visit->user->name,
                    'user_email' => $visit->user->email,
                    'client_name' => $visit->client_name,
                    'purpose' => $visit->purpose,
                    'status' => $visit->status,
                    'potential_value' => $visit->potential_value,
                    'notes' => $visit->notes,
                    'address' => $visit->address,
                    'latitude' => $visit->latitude,
                    'longitude' => $visit->longitude,
                    'visit_date' => $visit->created_at->format('Y-m-d H:i:s'),
                    'updated_at' => $visit->updated_at->format('Y-m-d H:i:s'),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $exportData,
                'total_records' => $visits->count(),
                'format' => $format,
                'exported_at' => Carbon::now()->toISOString()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to export KPI data'
            ], 500);
        }
    }

    // Private helper methods
    private function calculateOverallSuccessRate()
    {
        $totalVisits = KpiVisit::count();
        if ($totalVisits === 0) return 0;
        
        $successfulVisits = KpiVisit::where('status', 'success')->count();
        return round(($successfulVisits / $totalVisits) * 100, 2);
    }

    private function getDailyVisitsTrend($days = 30)
    {
        $startDate = Carbon::now()->subDays($days);
        
        return KpiVisit::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('COUNT(*) as visits'),
                DB::raw('SUM(CASE WHEN status = "success" THEN 1 ELSE 0 END) as successful_visits')
            )
            ->where('created_at', '>=', $startDate)
            ->groupBy(DB::raw('DATE(created_at)'))
            ->orderBy('date')
            ->get();
    }
}
