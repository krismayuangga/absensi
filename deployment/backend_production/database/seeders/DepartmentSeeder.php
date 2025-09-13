<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DepartmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('departments')->insert([
            [
                'id' => 1,
                'name' => 'Teknologi Informasi',
                'company_id' => 1,
                'description' => 'Departemen yang menangani teknologi dan sistem informasi',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'Sumber Daya Manusia',
                'company_id' => 1,
                'description' => 'Departemen yang menangani SDM dan kepegawaian',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3,
                'name' => 'Keuangan',
                'company_id' => 1,
                'description' => 'Departemen yang menangani keuangan dan akuntansi',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 4,
                'name' => 'Pemasaran',
                'company_id' => 1,
                'description' => 'Departemen yang menangani pemasaran dan penjualan',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 5,
                'name' => 'Operasional',
                'company_id' => 1,
                'description' => 'Departemen yang menangani operasional harian',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
