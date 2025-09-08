-- Sample data for Info & Media
INSERT INTO announcements (title, content, excerpt, priority, category, is_active, created_by) VALUES
('Selamat Datang di Sistem Absensi & KPI', 'Kami dengan bangga memperkenalkan sistem absensi dan KPI management yang baru. Sistem ini dirancang untuk meningkatkan efisiensi kerja dan monitoring performa karyawan.', 'Pengenalan sistem baru untuk absensi dan KPI management', 'high', 'Pengumuman', 1, 1),
('Update Kebijakan Cuti Tahun 2025', 'Mulai tahun 2025, terdapat perubahan kebijakan cuti yang perlu diperhatikan oleh seluruh karyawan. Silakan baca detail lengkap di attachment.', 'Perubahan kebijakan cuti terbaru', 'medium', 'Kebijakan', 1, 1),
('Training Mobile App Usage', 'Akan diadakan training penggunaan mobile app untuk semua karyawan. Training akan dilaksanakan secara bertahap per departemen.', 'Training penggunaan aplikasi mobile', 'medium', 'Training', 1, 1),
('Maintenance Server Weekend', 'Maintenance server akan dilakukan pada weekend tanggal 15-16 September 2025. Sistem mungkin tidak dapat diakses sementara.', 'Pemberitahuan maintenance server', 'low', 'Maintenance', 1, 1);

-- Sample comments
INSERT INTO announcement_comments (announcement_id, user_id, comment, is_approved) VALUES
(1, 1, 'Terima kasih atas sistem yang sangat membantu ini!', 1),
(2, 1, 'Apakah ada perubahan untuk cuti melahirkan?', 1),
(3, 1, 'Kapan jadwal training untuk departemen IT?', 1);
