<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Announcement;
use App\Models\User;

class AnnouncementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get first user as creator (or create admin if none exists)
        $admin = User::first() ?? User::create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
        ]);

        // Sample announcements
        $announcements = [
            [
                'title' => 'Selamat Datang di Sistem Absensi',
                'content' => 'Selamat datang di sistem absensi digital perusahaan. Fitur komentar dan like sekarang sudah tersedia untuk memudahkan komunikasi antar karyawan.',
                'excerpt' => 'Sistem absensi digital dengan fitur komunikasi',
                'priority' => 'high',
                'category' => 'system',
                'target_type' => 'all',
                'send_notification' => true,
                'created_by' => $admin->id,
            ],
            [
                'title' => 'Update Fitur Baru - Komentar dan Like',
                'content' => 'Kami telah menambahkan fitur komentar dan like pada sistem pengumuman. Anda dapat memberikan feedback dan berinteraksi dengan pengumuman yang ada.',
                'excerpt' => 'Fitur komentar dan like telah ditambahkan',
                'priority' => 'medium',
                'category' => 'feature',
                'target_type' => 'all',
                'send_notification' => false,
                'created_by' => $admin->id,
            ],
            [
                'title' => 'Panduan Penggunaan Aplikasi Mobile',
                'content' => 'Silakan pelajari panduan penggunaan aplikasi mobile untuk memaksimalkan fitur-fitur yang tersedia. Jika ada pertanyaan, silakan tinggalkan komentar.',
                'excerpt' => 'Panduan lengkap penggunaan aplikasi mobile',
                'priority' => 'low',
                'category' => 'guide',
                'target_type' => 'all',
                'send_notification' => false,
                'created_by' => $admin->id,
            ],
            [
                'title' => 'Testing Comment dan Like Feature',
                'content' => 'Ini adalah pengumuman khusus untuk testing fitur komentar dan like. Silakan coba berikan komentar dan like untuk memastikan semua berfungsi dengan baik.',
                'excerpt' => 'Pengumuman testing untuk fitur baru',
                'priority' => 'urgent',
                'category' => 'testing',
                'target_type' => 'all',
                'send_notification' => true,
                'created_by' => $admin->id,
            ],
        ];

        foreach ($announcements as $announcement) {
            Announcement::create($announcement);
        }
    }
}
