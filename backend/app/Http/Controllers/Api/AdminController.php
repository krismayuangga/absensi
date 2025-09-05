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
    /**
     * Get dashboard statistics
     */
    public function getDashboardStats()
    {
        try {
            // Real data from database
            $totalEmployees = User::where('role', 'employee')->where('is_active', true)->count();
            
            $today = Carbon::today();
            $todayAttendance = Attendance::whereDate('date', $today)
                ->where('status', 'present')
                ->distinct('user_id')
                ->count();
            
            $attendancePercentage = $totalEmployees > 0 
                ? round(($todayAttendance / $totalEmployees) * 100, 1) 
                : 0;
            
            $pendingLeaves = Leave::where('status', 'pending')->count();
            
            // Monthly average attendance
            $currentMonth = Carbon::now()->startOfMonth();
            $daysInMonth = Carbon::now()->diffInDays($currentMonth) + 1;
            $monthlyAttendance = Attendance::where('date', '>=', $currentMonth)
                ->where('status', 'present')
                ->distinct('user_id')
                ->count();
            $monthlyAverage = $daysInMonth > 0 ? round($monthlyAttendance / $daysInMonth, 1) : 0;
            
            // Additional statistics
            $lateToday = Attendance::whereDate('date', $today)
                ->whereTime('clock_in_time', '>', '08:30:00')
                ->count();
                
            $earlyLeaveToday = Attendance::whereDate('date', $today)
                ->whereTime('clock_out_time', '<', '17:00:00')
                ->whereNotNull('clock_out_time')
                ->count();
                
            $overtimeToday = Attendance::whereDate('date', $today)
                ->whereRaw('TIME(clock_out_time) > TIME("17:30:00")')
                ->whereNotNull('clock_out_time')
                ->count();
                
            // Weekly attendance trend
            $weeklyStats = [];
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::today()->subDays($i);
                $attendanceCount = Attendance::whereDate('date', $date)
                    ->where('status', 'present')
                    ->count();
                $weeklyStats[] = [
                    'tanggal' => $date->format('d/m'),
                    'hari' => $date->locale('id')->isoFormat('dddd'),
                    'hadir' => $attendanceCount,
                    'persentase' => $totalEmployees > 0 ? round(($attendanceCount / $totalEmployees) * 100) : 0
                ];
            }

            $stats = [
                'total_karyawan' => $totalEmployees,
                'hadir_hari_ini' => $todayAttendance,
                'persentase_kehadiran' => $attendancePercentage,
                'cuti_pending' => $pendingLeaves,
                'rata_rata_bulanan' => $monthlyAverage,
                'terlambat_hari_ini' => $lateToday,
                'pulang_cepat_hari_ini' => $earlyLeaveToday,
                'lembur_hari_ini' => $overtimeToday,
                'trend_mingguan' => $weeklyStats,
            ];
            
            // Recent activities from real data - dengan bahasa Indonesia
            $activities = Attendance::with('user:id,name,employee_id')
                ->whereDate('date', $today)
                ->latest('created_at')
                ->limit(10)
                ->get()
                ->map(function ($attendance) {
                    $action = 'Masuk';
                    $time = $attendance->clock_in_time;
                    $status = 'Tepat Waktu';
                    
                    // Determine action and status
                    if ($attendance->clock_out_time) {
                        $action = 'Keluar';
                        $time = $attendance->clock_out_time;
                        if (Carbon::parse($attendance->clock_out_time)->format('H:i') < '17:00') {
                            $status = 'Pulang Cepat';
                        } elseif (Carbon::parse($attendance->clock_out_time)->format('H:i') > '17:30') {
                            $status = 'Lembur';
                        } else {
                            $status = 'Normal';
                        }
                    } else {
                        if (Carbon::parse($attendance->clock_in_time)->format('H:i') > '08:30') {
                            $status = 'Terlambat';
                        }
                    }
                    
                    return [
                        'id' => $attendance->id,
                        'nama_karyawan' => $attendance->user->name ?? 'Unknown',
                        'kode_karyawan' => $attendance->user->employee_id ?? 'N/A',
                        'aksi' => $action,
                        'waktu' => Carbon::parse($time)->format('H:i'),
                        'tanggal' => $attendance->date,
                        'status' => $status,
                        'keterangan' => $attendance->notes ?? '-',
                    ];
                })
                ->toArray();

            return response()->json([
                'success' => true,
                'message' => 'Data dashboard berhasil dimuat',
                'data' => [
                    'statistik' => $stats,
                    'aktivitas_terkini' => $activities,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat data dashboard: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get detailed attendance report for dashboard
     */
    public function getDetailedAttendanceReport(Request $request)
    {
        try {
            $date = $request->get('date', Carbon::today()->format('Y-m-d'));
            $status = $request->get('status'); // present, late, early_leave, overtime
            
            $query = Attendance::with(['user:id,name,employee_id,position,department'])
                ->whereDate('date', $date);
                
            // Filter by status
            if ($status == 'late') {
                $query->whereTime('clock_in_time', '>', '08:30:00');
            } elseif ($status == 'early_leave') {
                $query->whereTime('clock_out_time', '<', '17:00:00')
                      ->whereNotNull('clock_out_time');
            } elseif ($status == 'overtime') {
                $query->whereTime('clock_out_time', '>', '17:30:00')
                      ->whereNotNull('clock_out_time');
            } elseif ($status == 'present') {
                $query->where('status', 'present');
            }
            
            $attendances = $query->get()->map(function ($attendance) {
                $clockIn = $attendance->clock_in_time ? Carbon::parse($attendance->clock_in_time) : null;
                $clockOut = $attendance->clock_out_time ? Carbon::parse($attendance->clock_out_time) : null;
                
                $status = 'Normal';
                $workingHours = 0;
                
                if ($clockIn && $clockIn->format('H:i') > '08:30') {
                    $status = 'Terlambat';
                }
                
                if ($clockOut) {
                    if ($clockOut->format('H:i') < '17:00') {
                        $status = 'Pulang Cepat';
                    } elseif ($clockOut->format('H:i') > '17:30') {
                        $status = 'Lembur';
                    }
                    
                    if ($clockIn) {
                        $workingHours = $clockOut->diffInMinutes($clockIn) / 60;
                    }
                }
                
                return [
                    'id' => $attendance->id,
                    'nama' => $attendance->user->name,
                    'kode_karyawan' => $attendance->user->employee_id,
                    'posisi' => $attendance->user->position ?? '-',
                    'departemen' => $attendance->user->department ?? '-',
                    'jam_masuk' => $clockIn ? $clockIn->format('H:i:s') : '-',
                    'jam_keluar' => $clockOut ? $clockOut->format('H:i:s') : '-',
                    'jam_kerja' => round($workingHours, 2),
                    'status' => $status,
                    'lokasi_masuk' => $attendance->clock_in_address ?? '-',
                    'lokasi_keluar' => $attendance->clock_out_address ?? '-',
                    'keterangan' => $attendance->notes ?? '-',
                    'tanggal' => Carbon::parse($attendance->date)->format('d/m/Y'),
                ];
            });
            
            return response()->json([
                'success' => true,
                'message' => 'Detail kehadiran berhasil dimuat',
                'data' => [
                    'tanggal' => Carbon::parse($date)->format('d/m/Y'),
                    'total' => $attendances->count(),
                    'kehadiran' => $attendances,
                ],
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat detail kehadiran: ' . $e->getMessage(),
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
                ->select([
                    'id', 'name', 'email', 'employee_id as employee_code', 
                    'phone', 'join_date', 'is_active as status',
                    'company_id', 'department', 'position'
                ]);
            
            if ($search) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('employee_id', 'like', "%{$search}%");
                });
            }
            
            $employees = $query->paginate($perPage);
            
            // Transform the data to match expected format - Bahasa Indonesia
            $transformedData = $employees->getCollection()->map(function ($employee) {
                return [
                    'id' => $employee->id,
                    'nama' => $employee->name,
                    'email' => $employee->email,
                    'kode_karyawan' => $employee->employee_code,
                    'telepon' => $employee->phone,
                    'tanggal_bergabung' => $employee->join_date ? Carbon::parse($employee->join_date)->format('d/m/Y') : '-',
                    'status' => $employee->status ? 'Aktif' : 'Non-Aktif',
                    'gaji' => 0, // Default value
                    'perusahaan' => ['id' => $employee->company_id ?? 1, 'nama' => 'PT. Kinerja Absensi'],
                    'departemen' => ['id' => 1, 'nama' => $employee->department ?? 'IT Department'],
                    'posisi' => ['id' => 1, 'nama' => $employee->position ?? 'Staff'],
                ];
            });
            
            $paginationData = [
                'data' => $transformedData,
                'halaman_saat_ini' => $employees->currentPage(),
                'halaman_terakhir' => $employees->lastPage(),
                'per_halaman' => $employees->perPage(),
                'total' => $employees->total(),
            ];
            
            return response()->json([
                'success' => true,
                'message' => 'Data karyawan berhasil dimuat',
                'data' => $paginationData,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat data karyawan: ' . $e->getMessage(),
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
            
            $query = Attendance::with(['user:id,name,employee_id']);
            
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
            
            $query = Leave::with(['user:id,name,employee_id']);
            
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
            // Real data from database or reasonable defaults - Bahasa Indonesia
            $companies = [
                ['id' => 1, 'nama' => 'PT. Kinerja Absensi'],
                ['id' => 2, 'nama' => 'Cabang Jakarta'],
                ['id' => 3, 'nama' => 'Cabang Bandung'],
            ];
            
            $departments = [
                ['id' => 1, 'nama' => 'Teknologi Informasi'],
                ['id' => 2, 'nama' => 'Sumber Daya Manusia'],
                ['id' => 3, 'nama' => 'Keuangan'],
                ['id' => 4, 'nama' => 'Pemasaran'],
                ['id' => 5, 'nama' => 'Operasional'],
            ];
            
            $positions = [
                ['id' => 1, 'nama' => 'Manajer'],
                ['id' => 2, 'nama' => 'Senior Developer'],
                ['id' => 3, 'nama' => 'Developer'],
                ['id' => 4, 'nama' => 'Staff'],
                ['id' => 5, 'nama' => 'Magang'],
                ['id' => 6, 'nama' => 'System Administrator'],
            ];

            return response()->json([
                'success' => true,
                'message' => 'Data master berhasil dimuat',
                'data' => [
                    'perusahaan' => $companies,
                    'departemen' => $departments,
                    'posisi' => $positions,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat data master: ' . $e->getMessage(),
            ], 500);
        }
    }
}
