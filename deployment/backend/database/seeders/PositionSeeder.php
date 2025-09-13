<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PositionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('positions')->insert([
            [
                'id' => 1,
                'name' => 'Manajer',
                'department_id' => 1,
                'description' => 'Manajer Teknologi Informasi',
                'base_salary' => 15000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'Senior Developer',
                'department_id' => 1,
                'description' => 'Senior Software Developer',
                'base_salary' => 12000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3,
                'name' => 'Developer',
                'department_id' => 1,
                'description' => 'Software Developer',
                'base_salary' => 8000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4,
                'name' => 'Staff HR',
                'department_id' => 2,
                'description' => 'Staff Sumber Daya Manusia',
                'base_salary' => 6000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 5,
                'name' => 'Magang',
                'department_id' => 1,
                'description' => 'Magang Teknologi Informasi',
                'base_salary' => 3000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 6,
                'name' => 'System Administrator',
                'department_id' => 1,
                'description' => 'Administrator Sistem',
                'base_salary' => 10000000.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
