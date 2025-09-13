<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KpiVisit;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class KpiController extends Controller
{
    /**
     * Get comprehensive KPI analytics data.
     */
    public function getStats(): JsonResponse
    {
        $user = Auth::user();
        
        // Basic counts
        $todayVisits = KpiVisit::where('user_id', $user->id)->today()->count();
        $weekVisits = KpiVisit::where('user_id', $user->id)->thisWeek()->count();
        $monthVisits = KpiVisit::where('user_id', $user->id)->thisMonth()->count();
        
        // Success metrics
        $successfulVisits = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->successful()
            ->count();
            
        $totalMonthVisits = KpiVisit::where('user_id', $user->id)->thisMonth()->count();
        $successRate = $totalMonthVisits > 0 ? round(($successfulVisits / $totalMonthVisits) * 100, 1) : 0;
        
        $totalPotentialValue = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->successful()
            ->sum('potential_value') ?? 0;

        // Visit breakdown by purpose (current month)
        $prospectingCount = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->where('visit_purpose', 'prospecting')
            ->count();
            
        $followUpCount = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->where('visit_purpose', 'follow_up')
            ->count();
            
        $closingCount = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->where('visit_purpose', 'closing')
            ->count();

        // Visit history for charts (last 30 days)
        $visitHistory = KpiVisit::where('user_id', $user->id)
            ->where('start_time', '>=', now()->subDays(30))
            ->orderBy('start_time', 'desc')
            ->get()
            ->map(function ($visit) {
                return [
                    'id' => $visit->id,
                    'client_name' => $visit->client_name,
                    'visit_purpose' => $visit->visit_purpose,
                    'status' => $visit->status,
                    'potential_value' => $visit->potential_value ?: 0,
                    'formatted_potential_value' => $visit->getFormattedPotentialValue(),
                    'start_time' => $visit->start_time->format('Y-m-d H:i:s'),
                    'address' => $visit->address,
                    'notes' => $visit->notes,
                ];
            });

        // Top clients (current month)
        $topClients = KpiVisit::where('user_id', $user->id)
            ->thisMonth()
            ->select('client_name')
            ->selectRaw('COUNT(*) as visit_count')
            ->selectRaw('SUM(CASE WHEN status = "success" THEN potential_value ELSE 0 END) as total_potential')
            ->groupBy('client_name')
            ->orderByDesc('visit_count')
            ->limit(10)
            ->get()
            ->map(function ($client) {
                return [
                    'name' => $client->client_name,
                    'visits' => $client->visit_count,
                    'potential_value' => $client->total_potential ?: 0,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'today_visits' => $todayVisits,
                'week_visits' => $weekVisits,
                'month_visits' => $monthVisits,
                'success_rate' => $successRate,
                'potential_value' => $totalPotentialValue,
                'formatted_potential_value' => 'Rp ' . number_format($totalPotentialValue, 0, ',', '.'),
                'avg_per_visit' => $totalMonthVisits > 0 ? round($totalPotentialValue / $totalMonthVisits, 0) : 0,
                'formatted_avg_per_visit' => $totalMonthVisits > 0 ? 'Rp ' . number_format($totalPotentialValue / $totalMonthVisits, 0, ',', '.') : 'Rp 0',
                'visits_by_purpose' => [
                    'prospecting' => $prospectingCount,
                    'follow_up' => $followUpCount,
                    'closing' => $closingCount,
                ],
                'visit_history' => $visitHistory,
                'top_clients' => $topClients,
            ],
        ]);
    }

    /**
     * Log a new visit.
     */
    public function logVisit(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'client_name' => 'required|string|max:255',
            'visit_purpose' => 'required|in:prospecting,follow_up,closing',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'address' => 'nullable|string|max:500',
            'start_time' => 'required|date',
            'notes' => 'nullable|string|max:1000',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data tidak valid',
                'errors' => $validator->errors(),
            ], 422);
        }

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('kpi-visits', 'public');
        }

        $visit = KpiVisit::create([
            'user_id' => Auth::id(),
            'client_name' => $request->client_name,
            'visit_purpose' => $request->visit_purpose,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'address' => $request->address,
            'start_time' => $request->start_time,
            'notes' => $request->notes,
            'photo_path' => $photoPath,
        ]);

        // AUTO-GENERATE NOTIFICATION when KPI visit is logged
        $this->createKpiNotification($visit, 'visit_logged');

        return response()->json([
            'status' => 'success',
            'message' => 'Kunjungan berhasil dicatat',
            'data' => [
                'id' => $visit->id,
                'client_name' => $visit->client_name,
                'visit_purpose' => $visit->getVisitPurposeIndonesian(),
                'start_time' => $visit->start_time->format('H:i'),
                'address' => $visit->address,
            ],
        ]);
    }

    /**
     * Update visit result.
     */
    public function updateResult(Request $request, $visitId): JsonResponse
    {
        $visit = KpiVisit::where('id', $visitId)
            ->where('user_id', Auth::id())
            ->first();

        if (!$visit) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kunjungan tidak ditemukan',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:success,failed',
            'end_time' => 'nullable|date|after:' . $visit->start_time,
            'potential_value' => 'nullable|numeric|min:0',
            'next_follow_up' => 'nullable|date|after:today',
            'next_action' => 'nullable|string|max:500',
            'probability_score' => 'nullable|integer|between:1,100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data tidak valid',
                'errors' => $validator->errors(),
            ], 422);
        }

        $visit->update([
            'status' => $request->status,
            'end_time' => $request->end_time ?? now(),
            'potential_value' => $request->potential_value,
            'next_follow_up' => $request->next_follow_up,
            'next_action' => $request->next_action,
            'probability_score' => $request->probability_score,
            'result_updated_at' => now(),
        ]);

        // AUTO-GENERATE NOTIFICATION when KPI result is updated
        $this->createKpiNotification($visit, 'result_updated');

        return response()->json([
            'status' => 'success',
            'message' => 'Hasil kunjungan berhasil diperbarui',
            'data' => [
                'id' => $visit->id,
                'status' => $visit->getStatusIndonesian(),
                'potential_value' => $visit->getFormattedPotentialValue(),
                'duration' => $visit->getDurationInMinutes() . ' menit',
            ],
        ]);
    }

    /**
     * Get visit history.
     */
    public function getHistory(Request $request): JsonResponse
    {
        $period = $request->get('period', 'week'); // today, week, month
        
        $query = KpiVisit::where('user_id', Auth::id())
            ->orderBy('start_time', 'desc');

        switch ($period) {
            case 'today':
                $query->today();
                break;
            case 'week':
                $query->thisWeek();
                break;
            case 'month':
                $query->thisMonth();
                break;
        }

        $visits = $query->get()->map(function ($visit) {
            return [
                'id' => $visit->id,
                'client_name' => $visit->client_name,
                'visit_purpose' => $visit->getVisitPurposeIndonesian(),
                'status' => $visit->getStatusIndonesian(),
                'start_time' => $visit->start_time->format('d/m/Y H:i'),
                'end_time' => $visit->end_time ? $visit->end_time->format('H:i') : null,
                'duration' => $visit->getDurationInMinutes() ? $visit->getDurationInMinutes() . ' menit' : 'Belum selesai',
                'potential_value' => $visit->getFormattedPotentialValue(),
                'address' => $visit->address,
                'notes' => $visit->notes,
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $visits,
        ]);
    }

    /**
     * Get pending visits (need result update).
     */
    public function getPendingVisits(): JsonResponse
    {
        $visits = KpiVisit::where('user_id', Auth::id())
            ->where('status', 'pending')
            ->orderBy('start_time', 'desc')
            ->get()
            ->map(function ($visit) {
                return [
                    'id' => $visit->id,
                    'client_name' => $visit->client_name,
                    'visit_purpose' => $visit->getVisitPurposeIndonesian(),
                    'start_time' => $visit->start_time->format('d/m/Y H:i'),
                    'address' => $visit->address,
                    'can_update' => true,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $visits,
        ]);
    }

    /**
     * Auto-generate notification when KPI activity happens
     */
    private function createKpiNotification(KpiVisit $visit, string $action)
    {
        try {
            $userId = $visit->user_id;
            
            switch ($action) {
                case 'visit_logged':
                    Notification::create([
                        'user_id' => $userId,
                        'type' => 'kpi_activity',
                        'title' => 'Kunjungan KPI Baru Tercatat',
                        'message' => "Kunjungan ke {$visit->client_name} berhasil dicatat. Jangan lupa update hasilnya!",
                        'priority' => 'medium',
                        'action_data' => [
                            'visit_id' => $visit->id,
                            'client_name' => $visit->client_name,
                            'visit_purpose' => $visit->visit_purpose,
                        ],
                        'is_read' => false,
                    ]);
                    break;

                case 'result_updated':
                    $title = $visit->status === 'success' ? 'Kunjungan Berhasil! 🎉' : 'Kunjungan Selesai';
                    $message = $visit->status === 'success' 
                        ? "Selamat! Kunjungan ke {$visit->client_name} berhasil dengan nilai potensial " . $visit->getFormattedPotentialValue()
                        : "Kunjungan ke {$visit->client_name} telah diselesaikan.";
                    
                    Notification::create([
                        'user_id' => $userId,
                        'type' => $visit->status === 'success' ? 'success' : 'kpi_activity',
                        'title' => $title,
                        'message' => $message,
                        'priority' => $visit->status === 'success' ? 'high' : 'medium',
                        'action_data' => [
                            'visit_id' => $visit->id,
                            'client_name' => $visit->client_name,
                            'status' => $visit->status,
                            'potential_value' => $visit->potential_value,
                        ],
                        'is_read' => false,
                    ]);
                    
                    // Check for milestone achievements
                    $this->checkMilestoneNotifications($userId);
                    break;
            }
        } catch (\Exception $e) {
            // Log error but don't break the main flow
            \Log::error('Failed to create KPI notification: ' . $e->getMessage());
        }
    }

    /**
     * Check and create milestone achievement notifications
     */
    private function checkMilestoneNotifications(int $userId)
    {
        try {
            $monthlySuccessful = KpiVisit::where('user_id', $userId)
                ->whereMonth('created_at', Carbon::now()->month)
                ->where('status', 'success')
                ->count();

            $milestones = [5, 10, 20, 30, 50];
            
            foreach ($milestones as $milestone) {
                if ($monthlySuccessful == $milestone) {
                    // Check if notification for this milestone already exists this month
                    $existingNotification = Notification::where('user_id', $userId)
                        ->where('type', 'milestone')
                        ->whereMonth('created_at', Carbon::now()->month)
                        ->where('action_data->milestone', $milestone)
                        ->exists();

                    if (!$existingNotification) {
                        Notification::create([
                            'user_id' => $userId,
                            'type' => 'milestone',
                            'title' => "Milestone Tercapai! 🏆",
                            'message' => "Luar biasa! Anda telah berhasil menyelesaikan {$milestone} kunjungan sukses bulan ini!",
                            'priority' => 'high',
                            'action_data' => [
                                'milestone' => $milestone,
                                'month' => Carbon::now()->format('Y-m'),
                                'total_successful' => $monthlySuccessful,
                            ],
                            'is_read' => false,
                        ]);
                    }
                    break; // Only one milestone notification per update
                }
            }
        } catch (\Exception $e) {
            \Log::error('Failed to create milestone notification: ' . $e->getMessage());
        }
    }
}
