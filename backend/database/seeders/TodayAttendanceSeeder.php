<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Attendance;
use Carbon\Carbon;

class TodayAttendanceSeeder extends Seeder
{
    public function run()
    {
        // Get the employee (Test Employee)
        $employee = User::where('role', 'employee')->first();
        
        if (!$employee) {
            $this->command->error('No employee found!');
            return;
        }
        
        $this->command->info("Creating attendance for: {$employee->name}");
        
        // Check if attendance already exists for today
        $today = Carbon::today();
        $existingAttendance = Attendance::where('user_id', $employee->id)
            ->whereDate('date', $today)
            ->first();
            
        if ($existingAttendance) {
            $this->command->info('Attendance for today already exists.');
            return;
        }
        
        // Create attendance for today
        $clockIn = $today->copy()->setTime(8, 15, 0); // 8:15 AM
        $clockOut = $today->copy()->setTime(17, 10, 0); // 5:10 PM
        $workingHours = abs($clockOut->diffInMinutes($clockIn)) / 60;
        
        Attendance::create([
            'user_id' => $employee->id,
            'date' => $today->format('Y-m-d'),
            'clock_in_time' => $clockIn->format('H:i:s'),
            'clock_out_time' => $clockOut->format('H:i:s'),
            'clock_in_latitude' => -6.2000000,
            'clock_in_longitude' => 106.8166600,
            'clock_out_latitude' => -6.2707500,
            'clock_out_longitude' => 106.8195830,
            'clock_in_address' => 'Jl. Sudirman No. 123, Jakarta',
            'clock_out_address' => 'Office Location - Jakarta',
            'working_hours' => round($workingHours, 2),
            'status' => 'present',
            'notes' => 'Today attendance for dashboard test',
            'created_at' => $clockIn,
            'updated_at' => $clockOut,
        ]);
        
        $this->command->info("Created attendance for {$employee->name} on {$today->format('Y-m-d')}");
        $this->command->info("Working hours: " . round($workingHours, 2));
    }
}
