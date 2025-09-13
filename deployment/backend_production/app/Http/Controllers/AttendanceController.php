<?php

namespace App\Http\Controllers;

use App\Models\Attendance;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class AttendanceController extends Controller
{
    /**
     * Get today's attendance for authenticated user
     */
    public function getTodayAttendance()
    {
        try {
            $user = Auth::user();
            $today = Carbon::today();
            
            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('date', $today)
                ->first();

            return response()->json([
                'success' => true,
                'data' => $attendance,
                'message' => $attendance ? 'Today attendance found' : 'No attendance record for today'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get attendance: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Clock in
     */
    public function clockIn(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'latitude' => 'required|numeric|between:-90,90',
                'longitude' => 'required|numeric|between:-180,180',
                'address' => 'nullable|string',
                'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
                // Field work fields
                'work_type' => 'nullable|in:office,field_work,meeting,survey,client_visit',
                'activity_description' => 'required_if:work_type,field_work,meeting,survey,client_visit|string|min:20',
                'client_name' => 'nullable|string|max:255',
                'notes' => 'nullable|string|max:500',
                // Anti-fake GPS fields
                'location_provider' => 'nullable|string',
                'location_accuracy' => 'nullable|numeric|min:0',
                'network_info' => 'nullable|string',
                'timestamp' => 'nullable|numeric'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            $today = Carbon::today();

            // Office location configuration with defensive programming
            $officeConfig = config('attendance.office', []);
            $officeLat = $officeConfig['latitude'] ?? -6.270075;
            $officeLng = $officeConfig['longitude'] ?? 106.819858;
            $officeRadius = $officeConfig['radius'] ?? 200;

            // Calculate distance from office
            $distance = $this->calculateDistance(
                $request->latitude, 
                $request->longitude, 
                $officeLat, 
                $officeLng
            );

            $isInOffice = $distance <= $officeRadius;
            $workType = $request->work_type ?? ($isInOffice ? 'office' : 'field_work');

            // Debug info
            error_log("User Lat: {$request->latitude}, Lng: {$request->longitude}");
            error_log("Office Lat: {$officeLat}, Lng: {$officeLng}");
            error_log("Distance: {$distance}m, Radius: {$officeRadius}m");
            error_log("Is In Office: " . ($isInOffice ? 'Yes' : 'No'));

            // Validation for field work with defensive programming
            if (!$isInOffice && $workType !== 'office') {
                $fieldWorkConfig = config('attendance.field_work', []);
                
                // If field work is disabled, reject attendance outside office
                if (!($fieldWorkConfig['enable_geofence'] ?? true)) {
                    return response()->json([
                        'success' => false,
                        'message' => "Anda berada {$distance}m dari kantor. Absensi hanya dapat dilakukan di area kantor (radius {$officeRadius}m)"
                    ], 422);
                }
                
                // Mandatory photo for field work
                if (($fieldWorkConfig['mandatory_photo'] ?? false) && !$request->hasFile('photo')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Foto selfie wajib untuk absensi di luar kantor'
                    ], 422);
                }

                // Mandatory activity description for field work
                if (($fieldWorkConfig['mandatory_description'] ?? false) && empty($request->activity_description)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Deskripsi kegiatan wajib diisi untuk absensi di luar kantor'
                    ], 422);
                }
            }

            // Check if already clocked in today
            $existingAttendance = Attendance::where('user_id', $user->id)
                ->whereDate('date', $today)
                ->first();

            if ($existingAttendance && $existingAttendance->clock_in_time) {
                return response()->json([
                    'success' => false,
                    'message' => 'Already clocked in today'
                ], 400);
            }

            $photoPath = null;
            if ($request->hasFile('photo')) {
                $photo = $request->file('photo');
                $filename = 'clock_in_' . $user->id . '_' . time() . '.' . $photo->getClientOriginalExtension();
                $photoPath = $photo->storeAs('attendance/clock_in', $filename, 'public');
            }

            $attendanceData = [
                'user_id' => $user->id,
                'date' => $today,
                'clock_in_time' => Carbon::now(),
                'clock_in_latitude' => (float) $request->latitude,
                'clock_in_longitude' => (float) $request->longitude,
                'clock_in_address' => $request->address,
                'clock_in_photo' => $photoPath,
                'status' => 'present',
                // Field work data
                'work_type' => $request->work_type ?? 'office',
                'activity_description' => $request->activity_description,
                'client_name' => $request->client_name,
                'notes' => $request->notes
            ];

            if ($existingAttendance) {
                $existingAttendance->update($attendanceData);
                $attendance = $existingAttendance;
            } else {
                $attendance = Attendance::create($attendanceData);
            }

            return response()->json([
                'success' => true,
                'data' => $attendance,
                'message' => 'Clock in successful'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to clock in: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Clock out
     */
    public function clockOut(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'latitude' => 'required|numeric',
                'longitude' => 'required|numeric',
                'address' => 'nullable|string',
                'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            $today = Carbon::today();

            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('date', $today)
                ->first();

            if (!$attendance || !$attendance->clock_in_time) {
                return response()->json([
                    'success' => false,
                    'message' => 'Must clock in first'
                ], 400);
            }

            if ($attendance->clock_out_time) {
                return response()->json([
                    'success' => false,
                    'message' => 'Already clocked out today'
                ], 400);
            }

            $photoPath = null;
            if ($request->hasFile('photo')) {
                $photo = $request->file('photo');
                $filename = 'clock_out_' . $user->id . '_' . time() . '.' . $photo->getClientOriginalExtension();
                $photoPath = $photo->storeAs('attendance/clock_out', $filename, 'public');
            }

            $clockOutTime = Carbon::now();
            $clockInTime = Carbon::parse($attendance->clock_in_time);
            
            // Ensure both times are in the same timezone
            $clockInTime = $clockInTime->setTimezone('Asia/Jakarta');
            $clockOutTime = $clockOutTime->setTimezone('Asia/Jakarta');
            
            // Calculate working hours with proper timezone
            $totalMinutes = $clockInTime->diffInMinutes($clockOutTime);
            $workingHours = $totalMinutes / 60;

            $attendance->update([
                'clock_out_time' => $clockOutTime,
                'clock_out_latitude' => (float) $request->latitude,
                'clock_out_longitude' => (float) $request->longitude,
                'clock_out_address' => $request->address,
                'clock_out_photo' => $photoPath,
                'working_hours' => $workingHours
            ]);

            return response()->json([
                'success' => true,
                'data' => $attendance,
                'message' => 'Clock out successful'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to clock out: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get attendance history
     */
    public function getAttendanceHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $limit = $request->get('limit', 10);
            $page = $request->get('page', 1);

            $attendances = Attendance::where('user_id', $user->id)
                ->orderBy('date', 'desc')
                ->paginate($limit);

            return response()->json([
                'success' => true,
                'data' => $attendances,
                'message' => 'Attendance history retrieved successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get attendance history: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get attendance statistics
     */
    public function getAttendanceStats(Request $request)
    {
        try {
            $user = Auth::user();
            $month = $request->get('month', Carbon::now()->month);
            $year = $request->get('year', Carbon::now()->year);

            $attendances = Attendance::where('user_id', $user->id)
                ->whereYear('date', $year)
                ->whereMonth('date', $month)
                ->get();

            $totalDays = $attendances->count();
            $presentDays = $attendances->where('status', 'present')->count();
            $lateDays = $attendances->where('status', 'late')->count();
            $absentDays = $attendances->where('status', 'absent')->count();
            $avgWorkingHours = $attendances->where('working_hours', '>', 0)->avg('working_hours');

            return response()->json([
                'success' => true,
                'data' => [
                    'total_days' => $totalDays,
                    'present_days' => $presentDays,
                    'late_days' => $lateDays,
                    'absent_days' => $absentDays,
                    'average_working_hours' => round($avgWorkingHours, 2) ?? 0,
                    'attendance_rate' => $totalDays > 0 ? round(($presentDays / $totalDays) * 100, 2) : 0
                ],
                'message' => 'Attendance statistics retrieved successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get attendance statistics: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Recalculate working hours for existing attendance
     */
    public function recalculateWorkingHours(Request $request)
    {
        try {
            $user = Auth::user();
            $date = $request->get('date', Carbon::today()->format('Y-m-d'));
            
            // Find attendance by clock_in_time date instead of date field
            $attendance = Attendance::where('user_id', $user->id)
                ->whereDate('clock_in_time', $date)
                ->first();

            if (!$attendance || !$attendance->clock_in_time || !$attendance->clock_out_time) {
                return response()->json([
                    'success' => false,
                    'message' => 'No complete attendance record found for the specified date'
                ], 404);
            }

            // Recalculate with proper timezone
            // Parse times as UTC first (since they're stored as UTC in database)
            $clockInTime = Carbon::parse($attendance->clock_in_time, 'UTC');
            $clockOutTime = Carbon::parse($attendance->clock_out_time, 'UTC');
            
            // Convert to Asia/Jakarta for display
            $clockInLocal = $clockInTime->setTimezone('Asia/Jakarta');
            $clockOutLocal = $clockOutTime->setTimezone('Asia/Jakarta');
            
            // Calculate difference in UTC (more accurate)
            $totalMinutes = $clockInTime->diffInMinutes($clockOutTime);
            $workingHours = $totalMinutes / 60;

            // Debug info
            error_log("Clock In UTC: " . $clockInTime->toDateTimeString());
            error_log("Clock Out UTC: " . $clockOutTime->toDateTimeString());
            error_log("Clock In Jakarta: " . $clockInLocal->toDateTimeString());
            error_log("Clock Out Jakarta: " . $clockOutLocal->toDateTimeString());
            error_log("Total Minutes: " . $totalMinutes);
            error_log("Working Hours: " . $workingHours);

            $attendance->update([
                'working_hours' => $workingHours
            ]);

            return response()->json([
                'success' => true,
                'data' => $attendance,
                'message' => 'Working hours recalculated successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to recalculate working hours: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Calculate distance between two points using Haversine formula
     */
    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // Earth radius in meters

        $lat1Rad = deg2rad($lat1);
        $lat2Rad = deg2rad($lat2);
        $deltaLatRad = deg2rad($lat2 - $lat1);
        $deltaLonRad = deg2rad($lon2 - $lon1);

        $a = sin($deltaLatRad / 2) * sin($deltaLatRad / 2) +
            cos($lat1Rad) * cos($lat2Rad) *
            sin($deltaLonRad / 2) * sin($deltaLonRad / 2);
        
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c;

        return $distance;
    }

    /**
     * Check if coordinates are suspiciously precise (fake GPS indicator)
     */
    private function isCoordinatesTooPrecise($lat, $lng)
    {
        // Real GPS rarely gives coordinates with more than 6 decimal places
        $latDecimals = strlen(substr(strrchr($lat, "."), 1));
        $lngDecimals = strlen(substr(strrchr($lng, "."), 1));
        
        return ($latDecimals > 8 || $lngDecimals > 8);
    }

    /**
     * Detect teleportation (impossible movement speed)
     */
    private function detectTeleportation($lastAttendance, $currentLat, $currentLng)
    {
        if (!$lastAttendance || !$lastAttendance->clock_in_latitude || !$lastAttendance->clock_in_longitude) {
            return false;
        }

        $distance = $this->calculateDistance(
            $lastAttendance->clock_in_latitude,
            $lastAttendance->clock_in_longitude,
            $currentLat,
            $currentLng
        );

        $timeDiff = Carbon::now()->diffInSeconds($lastAttendance->created_at);
        $maxPossibleSpeed = 200; // km/h (very generous for any normal transportation)
        
        $maxPossibleDistance = ($maxPossibleSpeed * 1000 / 3600) * $timeDiff; // meters
        
        return $distance > $maxPossibleDistance;
    }
}
