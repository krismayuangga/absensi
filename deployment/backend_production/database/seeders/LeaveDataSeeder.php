<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Leave;
use App\Models\User;
use Carbon\Carbon;

class LeaveDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::where('employee_id', 'EMP001')->first();
        
        if ($user) {
            // Create some sample leave requests
            Leave::create([
                'user_id' => $user->id,
                'employee_id' => $user->employee_id,
                'type' => 'annual',
                'start_date' => Carbon::now()->addDays(5),
                'end_date' => Carbon::now()->addDays(7),
                'total_days' => 3,
                'reason' => 'Liburan keluarga',
                'status' => 'pending',
                'created_at' => Carbon::now()->subHours(2),
            ]);

            Leave::create([
                'user_id' => $user->id,
                'employee_id' => $user->employee_id,
                'type' => 'sick',
                'start_date' => Carbon::now()->subDays(3),
                'end_date' => Carbon::now()->subDays(1),
                'total_days' => 3,
                'reason' => 'Demam dan flu',
                'status' => 'approved',
                'approved_by' => $user->id,
                'approved_at' => Carbon::now()->subDays(2),
                'manager_notes' => 'Semoga cepat sembuh',
                'created_at' => Carbon::now()->subDays(4),
            ]);

            Leave::create([
                'user_id' => $user->id,
                'employee_id' => $user->employee_id,
                'type' => 'personal',
                'start_date' => Carbon::now()->addDays(15),
                'end_date' => Carbon::now()->addDays(16),
                'total_days' => 2,
                'reason' => 'Urusan keluarga',
                'status' => 'approved',
                'approved_by' => $user->id,
                'approved_at' => Carbon::now()->subHours(1),
                'manager_notes' => 'Disetujui',
                'created_at' => Carbon::now()->subHours(3),
            ]);
        }
    }
}