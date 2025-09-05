<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;

class TestUsersWithAttendanceSeeder extends Seeder
{
    public function run()
    {
        $this->command->info('Creating test users and attendance data...');
        
        // Create multiple test employees
        $employees = [
            [
                'name' => 'Ahmad Wijaya',
                'email' => 'ahmad.wijaya@company.com',
                'employee_id' => 'EMP004',
                'phone' => '081234567895',
                'join_date' => '2024-01-15',
                'position' => 'Frontend Developer',
                'department' => 'IT',
                'role' => 'employee',
                'is_active' => true,
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Siti Nurhaliza',
                'email' => 'siti.nurhaliza@company.com',
                'employee_id' => 'EMP005',
                'phone' => '081234567896',
                'join_date' => '2024-02-10',
                'position' => 'UI/UX Designer',
                'department' => 'IT',
                'role' => 'employee',
                'is_active' => true,
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Budi Santoso',
                'email' => 'budi.santoso@company.com',
                'employee_id' => 'EMP006',
                'phone' => '081234567897',
                'join_date' => '2024-03-05',
                'position' => 'Backend Developer',
                'department' => 'IT',
                'role' => 'employee',
                'is_active' => true,
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Maya Sari',
                'email' => 'maya.sari@company.com',
                'employee_id' => 'EMP007',
                'phone' => '081234567898',
                'join_date' => '2024-04-12',
                'position' => 'Project Manager',
                'department' => 'Operations',
                'role' => 'employee',
                'is_active' => true,
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Rizki Pratama',
                'email' => 'rizki.pratama@company.com',
                'employee_id' => 'EMP008',
                'phone' => '081234567899',
                'join_date' => '2024-05-20',
                'position' => 'QA Tester',
                'department' => 'IT',
                'role' => 'employee',
                'is_active' => true,
                'password' => Hash::make('password123'),
            ],
        ];

        // Create employees if they don't exist
        foreach ($employees as $employeeData) {
            $existing = User::where('employee_id', $employeeData['employee_id'])->first();
            if (!$existing) {
                User::create($employeeData);
                $this->command->info("Created employee: {$employeeData['name']} ({$employeeData['employee_id']})");
            } else {
                $this->command->info("Employee already exists: {$employeeData['name']} ({$employeeData['employee_id']})");
            }
        }

        // Get all employees
        $allEmployees = User::where('role', 'employee')->get();
        $this->command->info("Total employees found: " . $allEmployees->count());

        // Clear existing attendance for today
        $today = Carbon::today();
        Attendance::whereDate('date', $today)->delete();
        $this->command->info("Cleared existing attendance for today");

        // Create attendance for today - simulate realistic office scenario
        foreach ($allEmployees as $employee) {
            // 80% chance of attendance for today
            if (rand(1, 100) <= 80) {
                $clockInHour = rand(7, 9); // 7:00 AM - 9:00 AM
                $clockInMinute = rand(0, 59);
                $clockIn = $today->copy()->setTime($clockInHour, $clockInMinute, 0);
                
                // Some people haven't clocked out yet
                $clockOut = null;
                if (rand(1, 100) <= 70) { // 70% have clocked out
                    $clockOutHour = rand(17, 19); // 5:00 PM - 7:00 PM
                    $clockOutMinute = rand(0, 59);
                    $clockOut = $today->copy()->setTime($clockOutHour, $clockOutMinute, 0);
                }
                
                $workingHours = 0;
                if ($clockOut) {
                    $workingHours = abs($clockOut->diffInMinutes($clockIn)) / 60;
                }
                
                Attendance::create([
                    'user_id' => $employee->id,
                    'date' => $today->format('Y-m-d'),
                    'clock_in_time' => $clockIn->format('H:i:s'),
                    'clock_out_time' => $clockOut ? $clockOut->format('H:i:s') : null,
                    'clock_in_latitude' => -6.2000000 + (rand(-1000, 1000) / 100000),
                    'clock_in_longitude' => 106.8166600 + (rand(-1000, 1000) / 100000),
                    'clock_out_latitude' => $clockOut ? (-6.2707500 + (rand(-1000, 1000) / 100000)) : null,
                    'clock_out_longitude' => $clockOut ? (106.8195830 + (rand(-1000, 1000) / 100000)) : null,
                    'clock_in_address' => 'Jl. Sudirman No. 123, Jakarta',
                    'clock_out_address' => $clockOut ? 'Office Location - Jakarta' : null,
                    'working_hours' => round($workingHours, 2),
                    'status' => 'present',
                    'notes' => 'Daily attendance - ' . $today->format('d/m/Y'),
                    'created_at' => $clockIn,
                    'updated_at' => $clockOut ?? $clockIn,
                ]);
                
                $status = $clockOut ? 'masuk & keluar' : 'masuk saja';
                $this->command->info("Created attendance for {$employee->name} - {$status}");
            }
        }

        // Create attendance for past week
        for ($i = 1; $i <= 7; $i++) {
            $date = Carbon::today()->subDays($i);
            
            // Skip weekends
            if ($date->isWeekend()) {
                continue;
            }
            
            foreach ($allEmployees as $employee) {
                // 90% chance of attendance for past days
                if (rand(1, 100) <= 90) {
                    $clockIn = $date->copy()->setTime(8, rand(0, 30), 0);
                    $clockOut = $date->copy()->setTime(17, rand(0, 30), 0);
                    $workingHours = abs($clockOut->diffInMinutes($clockIn)) / 60;
                    
                    $existing = Attendance::where('user_id', $employee->id)
                        ->whereDate('date', $date)
                        ->first();
                        
                    if (!$existing) {
                        Attendance::create([
                            'user_id' => $employee->id,
                            'date' => $date->format('Y-m-d'),
                            'clock_in_time' => $clockIn->format('H:i:s'),
                            'clock_out_time' => $clockOut->format('H:i:s'),
                            'clock_in_latitude' => -6.2000000 + (rand(-1000, 1000) / 100000),
                            'clock_in_longitude' => 106.8166600 + (rand(-1000, 1000) / 100000),
                            'clock_out_latitude' => -6.2707500 + (rand(-1000, 1000) / 100000),
                            'clock_out_longitude' => 106.8195830 + (rand(-1000, 1000) / 100000),
                            'clock_in_address' => 'Jl. Sudirman No. 123, Jakarta',
                            'clock_out_address' => 'Office Location - Jakarta',
                            'working_hours' => round($workingHours, 2),
                            'status' => 'present',
                            'notes' => 'Daily attendance - ' . $date->format('d/m/Y'),
                            'created_at' => $clockIn,
                            'updated_at' => $clockOut,
                        ]);
                    }
                }
            }
        }

        // Create some leave requests - Skip for now due to table schema
        $this->command->info("Skipping leave requests due to schema requirements");
        
        // Summary
        $totalEmployees = User::where('role', 'employee')->count();
        $todayAttendance = Attendance::whereDate('date', $today)->count();
        $pendingLeaves = Leave::where('status', 'pending')->count();
        
        $this->command->info('=== SUMMARY ===');
        $this->command->info("Total Employees: {$totalEmployees}");
        $this->command->info("Today's Attendance: {$todayAttendance}");
        $this->command->info("Pending Leaves: {$pendingLeaves}");
        $this->command->info('=== DATA CREATION COMPLETE ===');
    }
}
