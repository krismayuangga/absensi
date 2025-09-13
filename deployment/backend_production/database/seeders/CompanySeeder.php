<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CompanySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('companies')->insert([
            [
                'id' => 1,
                'name' => 'PT. Kinerja Absensi',
                'address' => 'Jl. Sudirman No. 123, Jakarta Pusat',
                'phone' => '021-12345678',
                'email' => 'info@kinerjaabsensi.com',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'name' => 'Cabang Jakarta',
                'address' => 'Jl. Thamrin No. 456, Jakarta Pusat',
                'phone' => '021-87654321',
                'email' => 'jakarta@kinerjaabsensi.com',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 3,
                'name' => 'Cabang Bandung',
                'address' => 'Jl. Asia Afrika No. 789, Bandung',
                'phone' => '022-11223344',
                'email' => 'bandung@kinerjaabsensi.com',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
