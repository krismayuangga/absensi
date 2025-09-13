<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\KpiVisit;
use Carbon\Carbon;

class DebugKpiController extends Controller
{
    /**
     * Debug KPI stats without authentication
     */
    public function debugStats(): JsonResponse
    {
        try {
            // Mock data for testing
            $stats = [
                'today_visits' => 3,
                'week_visits' => 15,
                'month_visits' => 47,
                'success_rate' => 72.5,
                'potential_value' => 2500000,
                'formatted_potential_value' => 'Rp 2.500.000'
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error getting KPI stats: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Debug log visit without authentication
     */
    public function debugLogVisit(Request $request): JsonResponse
    {
        try {
            // Validate required fields
            $validated = $request->validate([
                'client_name' => 'required|string|max:255',
                'visit_purpose' => 'required|string|in:prospecting,follow_up,closing',
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'address' => 'nullable|string',
                'start_time' => 'required|date',
                'notes' => 'nullable|string'
            ]);

            // For debugging, just return success without saving to database
            $mockVisit = [
                'id' => rand(1000, 9999),
                'client_name' => $validated['client_name'],
                'visit_purpose' => $validated['visit_purpose'],
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'address' => $validated['address'] ?? null,
                'notes' => $validated['notes'] ?? null,
                'start_time' => $validated['start_time'],
                'created_at' => now()->toISOString()
            ];

            return response()->json([
                'success' => true,
                'message' => 'Visit logged successfully (DEBUG MODE)',
                'data' => $mockVisit
            ]);
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error logging visit: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Debug get visits without authentication
     */
    public function debugGetVisits(): JsonResponse
    {
        try {
            // Mock data for testing
            $visits = [
                [
                    'id' => 1,
                    'client_name' => 'PT Maju Jaya',
                    'visit_purpose' => 'prospecting',
                    'status' => 'pending',
                    'latitude' => -6.2608,
                    'longitude' => 106.7811,
                    'address' => 'Jakarta Pusat',
                    'created_at' => Carbon::now()->subDay()->toISOString()
                ],
                [
                    'id' => 2,
                    'client_name' => 'CV Sukses Mandiri',
                    'visit_purpose' => 'closing',
                    'status' => 'success',
                    'latitude' => -6.2000,
                    'longitude' => 106.8000,
                    'address' => 'Jakarta Selatan',
                    'created_at' => Carbon::now()->subDays(3)->toISOString()
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => $visits
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error getting visits: ' . $e->getMessage()
            ], 500);
        }
    }
}
