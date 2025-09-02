<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@test.com',
            'employee_id' => 'EMP001',
            'password' => Hash::make('123456'),
            'phone' => '+62812345678',
            'role' => 'admin',
            'position' => 'System Administrator',
            'department' => 'IT',
            'is_active' => true,
        ]);

        // Create manager user
        User::create([
            'name' => 'Manager User',
            'email' => 'manager@test.com',
            'employee_id' => 'EMP002',
            'password' => Hash::make('123456'),
            'phone' => '+62812345679',
            'role' => 'manager',
            'position' => 'Department Manager',
            'department' => 'Operations',
            'is_active' => true,
        ]);

        // Create employee user
        User::create([
            'name' => 'Employee User',
            'email' => 'employee@test.com',
            'employee_id' => 'EMP003',
            'password' => Hash::make('123456'),
            'phone' => '+62812345680',
            'role' => 'employee',
            'position' => 'Staff',
            'department' => 'Operations',
            'is_active' => true,
        ]);
    }
}
