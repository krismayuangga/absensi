<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MasterDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Insert companies
        $companies = [
            [
                'id' => 1,
                'name' => 'PT Kinerja Absensi',
                'address' => 'Jakarta, Indonesia',
                'phone' => '+62-21-1234567',
                'email' => 'info@kinerjaabsensi.com',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'PT Digital Solutions',
                'address' => 'Bandung, Indonesia',
                'phone' => '+62-22-1234567',
                'email' => 'info@digitalsolutions.com',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Insert departments
        $departments = [
            [
                'id' => 1,
                'name' => 'Human Resources',
                'company_id' => 1,
                'description' => 'Manages employee relations and company policies',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'Information Technology',
                'company_id' => 1,
                'description' => 'Handles technology infrastructure and development',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3,
                'name' => 'Finance',
                'company_id' => 1,
                'description' => 'Manages financial operations and accounting',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4,
                'name' => 'Marketing',
                'company_id' => 1,
                'description' => 'Handles marketing and customer relations',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 5,
                'name' => 'Operations',
                'company_id' => 2,
                'description' => 'Manages daily operations and processes',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Insert positions
        $positions = [
            // HR Department
            [
                'id' => 1,
                'name' => 'HR Manager',
                'department_id' => 1,
                'description' => 'Manages HR department and policies',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'HR Specialist',
                'department_id' => 1,
                'description' => 'Handles employee recruitment and development',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            
            // IT Department
            [
                'id' => 3,
                'name' => 'IT Manager',
                'department_id' => 2,
                'description' => 'Manages IT infrastructure and team',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4,
                'name' => 'Software Developer',
                'department_id' => 2,
                'description' => 'Develops and maintains software applications',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 5,
                'name' => 'System Administrator',
                'department_id' => 2,
                'description' => 'Maintains and monitors system infrastructure',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            
            // Finance Department
            [
                'id' => 6,
                'name' => 'Finance Manager',
                'department_id' => 3,
                'description' => 'Manages financial operations',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 7,
                'name' => 'Accountant',
                'department_id' => 3,
                'description' => 'Handles accounting and bookkeeping',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            
            // Marketing Department
            [
                'id' => 8,
                'name' => 'Marketing Manager',
                'department_id' => 4,
                'description' => 'Manages marketing strategies and campaigns',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 9,
                'name' => 'Digital Marketing Specialist',
                'department_id' => 4,
                'description' => 'Handles digital marketing and social media',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            
            // Operations Department (Company 2)
            [
                'id' => 10,
                'name' => 'Operations Manager',
                'department_id' => 5,
                'description' => 'Manages daily operations',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Clear existing data (optional - be careful in production)
        DB::table('positions')->delete();
        DB::table('departments')->delete();
        DB::table('companies')->delete();

        // Insert new data
        DB::table('companies')->insert($companies);
        DB::table('departments')->insert($departments);
        DB::table('positions')->insert($positions);

        $this->command->info('Master data seeded successfully!');
        $this->command->info('Companies: ' . count($companies));
        $this->command->info('Departments: ' . count($departments));
        $this->command->info('Positions: ' . count($positions));
    }
}
