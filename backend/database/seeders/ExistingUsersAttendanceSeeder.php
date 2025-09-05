<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;

class ExistingUsersAttendanceSeeder extends Seeder
{
    public function run()
    {
        // Get existing employees (exclude admin and manager for attendance)
        $employees = User::where('role', 'employee')->get();
        
        if ($employees->count() == 0) {
            $this->command->warn('No employees found in database.');
            return;
        }
        
        $this->command->info("Found {$employees->count()} employees. Creating attendance data...");

        // Clear existing attendance data first (optional)
        $existingAttendance = Attendance::count();
        if ($existingAttendance > 0) {
            $this->command->info("Found {$existingAttendance} existing attendance records. Skipping to avoid duplicates.");
            return;
        }

        // Create attendance records for the last 7 days for existing employees
        for ($i = 0; $i < 7; $i++) {
            $date = Carbon::today()->subDays($i);
            
            // Skip weekends
            if ($date->isWeekend()) {
                continue;
            }
            
            foreach ($employees as $employee) {
                // 90% chance of attendance
                if (rand(1, 100) <= 90) {
                    $clockIn = $date->copy()->setTime(8, rand(0, 30), 0);
                    $clockOut = $date->copy()->setTime(17, rand(0, 30), 0);
                    $workingHours = $clockOut->diffInMinutes($clockIn) / 60;
                    
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
                        'notes' => 'Regular daily attendance',
                        'created_at' => $clockIn,
                        'updated_at' => $clockOut,
                    ]);
                    
                    $this->command->info("Created attendance for {$employee->name} on {$date->format('Y-m-d')}");
                }
            }
        }
        
        // Create some leave requests for existing employees
        $leaveCount = Leave::count();
        if ($leaveCount == 0) {
            $leaveTypes = ['annual', 'sick', 'personal'];
            $statuses = ['pending', 'approved', 'rejected'];

            foreach ($employees as $employee) {
                // Create 1-2 leave requests per employee
                for ($j = 0; $j < rand(1, 2); $j++) {
                    $startDate = Carbon::today()->addDays(rand(1, 30));
                    $endDate = $startDate->copy()->addDays(rand(1, 3));
                    
                    Leave::create([
                        'user_id' => $employee->id,
                        'type' => $leaveTypes[array_rand($leaveTypes)],
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                        'days' => $startDate->diffInDays($endDate) + 1,
                        'reason' => 'Personal leave request - ' . $leaveTypes[array_rand($leaveTypes)],
                        'status' => $statuses[array_rand($statuses)],
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
            
            $this->command->info('Created sample leave requests for existing employees.');
        }

        $this->command->info('Attendance data creation completed for existing users!');
    }
}
