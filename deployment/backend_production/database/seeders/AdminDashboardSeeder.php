<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;

class AdminDashboardSeeder extends Seeder
{
    public function run()
    {
        // Only create data if no employees exist yet (except admin)
        $employeeCount = User::where('role', 'employee')->count();
        
        if ($employeeCount > 0) {
            $this->command->info('Sample employees already exist. Skipping employee creation.');
        } else {
            // Create sample employees
            $employees = [
                [
                    'name' => 'John Doe',
                    'email' => 'john.doe@company.com',
                    'employee_id' => 'EMP002',
                    'phone' => '081234567890',
                    'join_date' => '2024-01-15',
                    'position' => 'Senior Developer',
                    'department' => 'IT',
                    'role' => 'employee',
                    'is_active' => true,
                    'password' => Hash::make('password123'),
                ],
                [
                    'name' => 'Jane Smith',
                    'email' => 'jane.smith@company.com',
                    'employee_id' => 'EMP003',
                    'phone' => '081234567891',
                    'join_date' => '2024-02-10',
                    'position' => 'Manager',
                    'department' => 'HR',
                    'role' => 'employee',
                    'is_active' => true,
                    'password' => Hash::make('password123'),
                ],
                [
                    'name' => 'Bob Wilson',
                    'email' => 'bob.wilson@company.com',
                    'employee_id' => 'EMP004',
                    'phone' => '081234567892',
                    'join_date' => '2024-03-05',
                    'position' => 'Developer',
                    'department' => 'IT',
                    'role' => 'employee',
                    'is_active' => true,
                    'password' => Hash::make('password123'),
                ],
                [
                    'name' => 'Alice Johnson',
                    'email' => 'alice.johnson@company.com',
                    'employee_id' => 'EMP005',
                    'phone' => '081234567893',
                    'join_date' => '2024-04-12',
                    'position' => 'Staff',
                    'department' => 'Finance',
                    'role' => 'employee',
                    'is_active' => true,
                    'password' => Hash::make('password123'),
                ],
                [
                    'name' => 'Mike Brown',
                    'email' => 'mike.brown@company.com',
                    'employee_id' => 'EMP006',
                    'phone' => '081234567894',
                    'join_date' => '2024-05-20',
                    'position' => 'Marketing Staff',
                    'department' => 'Marketing',
                    'role' => 'employee',
                    'is_active' => true,
                    'password' => Hash::make('password123'),
                ],
            ];

            foreach ($employees as $employeeData) {
                User::create($employeeData);
            }
            
            $this->command->info('Sample employees created successfully!');
        }

        // Get all employees
        $allEmployees = User::where('role', 'employee')->get();
        
        if ($allEmployees->count() == 0) {
            $this->command->warn('No employees found. Cannot create attendance records.');
            return;
        }

        // Check if attendance records already exist for today
        $attendanceToday = Attendance::whereDate('date', Carbon::today())->count();
        
        if ($attendanceToday > 0) {
            $this->command->info('Attendance records for recent days already exist. Skipping attendance creation.');
        } else {
            // Create attendance records for the last 7 days
            for ($i = 0; $i < 7; $i++) {
                $date = Carbon::today()->subDays($i);
                
                foreach ($allEmployees as $employee) {
                    // 90% chance of attendance
                    if (rand(1, 100) <= 90) {
                        $clockIn = $date->copy()->setTime(8, rand(0, 30), 0);
                        $clockOut = $date->copy()->setTime(17, rand(0, 30), 0);
                        $workingHours = $clockOut->diffInMinutes($clockIn) / 60; // Convert to hours
                        
                        Attendance::create([
                            'user_id' => $employee->id,
                            'date' => $date->format('Y-m-d'),
                            'clock_in_time' => $clockIn->format('H:i:s'),
                            'clock_out_time' => $clockOut->format('H:i:s'),
                            'clock_in_latitude' => -6.2000000 + (rand(-1000, 1000) / 100000), // Jakarta area
                            'clock_in_longitude' => 106.8166600 + (rand(-1000, 1000) / 100000),
                            'clock_out_latitude' => -6.2707500 + (rand(-1000, 1000) / 100000),
                            'clock_out_longitude' => 106.8195830 + (rand(-1000, 1000) / 100000),
                            'clock_in_address' => 'Jl. Kemang Dalam III Blok I No.21, Bangka, Kecamat...',
                            'clock_out_address' => 'Test Office Location',
                            'working_hours' => round($workingHours, 2),
                            'status' => 'present',
                            'notes' => 'Regular attendance',
                            'created_at' => $clockIn,
                            'updated_at' => $clockOut,
                        ]);
                    }
                }
            }
            
            $this->command->info('Sample attendance records created successfully!');
        }

        // Check if leave requests already exist
        $leaveCount = Leave::count();
        
        if ($leaveCount > 0) {
            $this->command->info('Leave requests already exist. Skipping leave creation.');
        } else {
            // Create some leave requests
            $leaveTypes = ['annual', 'sick', 'personal', 'emergency'];
            $statuses = ['pending', 'approved', 'rejected'];

            for ($i = 0; $i < 5; $i++) {
                $employee = $allEmployees->random();
                $startDate = Carbon::today()->addDays(rand(1, 30));
                $endDate = $startDate->copy()->addDays(rand(1, 5));
                
                Leave::create([
                    'user_id' => $employee->id,
                    'type' => $leaveTypes[array_rand($leaveTypes)],
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                    'days' => $startDate->diffInDays($endDate) + 1,
                    'reason' => 'Sample leave request reason',
                    'status' => $statuses[array_rand($statuses)],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
            
            $this->command->info('Sample leave requests created successfully!');
        }

        $this->command->info('Admin dashboard sample data setup complete!');
    }
}
