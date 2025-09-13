PANDUAN DEPLOYMENT HOSTING DOMAINESIA
====================================

🚀 **SIAP UNTUK DEPLOYMENT PRODUKSI**

## 📁 FILE YANG SUDAH DISIAPKAN
Backend Laravel Anda telah disiapkan untuk hosting Domainesia di:
`deployment/backend_production/`

## 📋 LANGKAH-LANGKAH DEPLOYMENT

### 1. **UPLOAD FILE KE DOMAINESIA**
1. Login ke cPanel Domainesia Anda
2. Buka **File Manager**
3. Masuk ke direktori `public_html`

**PENTING - Struktur Folder yang Benar:**
```
public_html/
├── index.php          ← Dari folder public/ Laravel
├── .htaccess          ← Dari folder public/ Laravel  
├── css/, js/          ← Assets dari public/ (jika ada)
└── laravel/           ← Semua file Laravel lainnya
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── vendor/
    └── .env
```

4. **Upload dengan cara:**
   - Buat folder `laravel` di `public_html`
   - Upload semua file Laravel ke folder `laravel/`
   - Copy isi folder `public/` ke root `public_html`
   - Edit `index.php` untuk menunjuk ke `laravel/`

### 2. **SETUP DATABASE**
1. Di cPanel, buka **MySQL Databases**
2. Buat database baru (contoh: `namasite_attendance`)
3. Buat user database dengan hak akses penuh
4. Catat nama database, username, dan password

### 3. **KONFIGURASI ENVIRONMENT**
1. Di File Manager, edit file `.env` di `public_html`
2. Update pengaturan penting berikut:
   ```
   APP_URL=https://namadomainanda.com
   APP_ENV=production
   APP_DEBUG=false
   
   DB_DATABASE=namasite_attendance
   DB_USERNAME=namasite_dbuser
   DB_PASSWORD=password_aman_anda
   ```

### 4. **GENERATE SECURITY KEYS**
Jika tersedia, jalankan perintah berikut melalui Terminal cPanel atau SSH:
```bash
php artisan key:generate --force
php artisan jwt:secret --force
```

### 5. **SETUP DATABASE**

**Opsi A: Import Database Manual (Disarankan)**
1. Export database lokal Anda:
   ```bash
   # Via mysqldump
   mysqldump -u root -p nama_database_lokal > backup_database.sql
   
   # Atau via phpMyAdmin: Database → Export → Go
   ```

2. Import ke database Domainesia:
   - Login ke cPanel Domainesia
   - Buka **phpMyAdmin** 
   - Pilih database yang sudah dibuat
   - Klik **Import** → Choose file → Upload `backup_database.sql`
   - Klik **Go**

**Opsi B: Migration Laravel (Jika Terminal Tersedia)**
```bash
php artisan migrate --force
php artisan db:seed --force
```

### 6. **VERIFIKASI AKHIR**
- Kunjungi website Anda: `https://namadomainanda.com`
- Test endpoint API: `https://namadomainanda.com/api/test`
- Pastikan login admin berfungsi

## ⚠️ **CATATAN KEAMANAN PENTING**

1. **Keamanan File Environment**
   - Jangan pernah commit `.env` ke version control
   - Jaga kerahasiaan kredensial database
   - Gunakan password yang kuat

2. **Pengaturan Produksi**
   - Pastikan `APP_DEBUG=false`
   - Set `APP_URL` yang benar
   - Gunakan HTTPS di produksi

3. **Izin File**
   - `storage/` dan `bootstrap/cache/` harus dapat ditulis
   - File lainnya hanya baca saja

## 📱 **KONFIGURASI APLIKASI MOBILE**

Update URL API di aplikasi Flutter Anda:
```dart
// Di lib/core/constants/api_constants.dart
static const String baseUrl = 'https://namadomainanda.com/api';
```

## 🔧 **TROUBLESHOOTING**

**Masalah Umum:**

1. **500 Internal Server Error**
   - Periksa izin file (755 untuk direktori, 644 untuk file)
   - Pastikan file `.env` dikonfigurasi dengan benar
   - Periksa `storage/logs/laravel.log` untuk error

2. **Error Koneksi Database**
   - Verifikasi kredensial database di `.env`
   - Pastikan user database memiliki hak akses yang tepat
   - Periksa hostname server database (biasanya `localhost`)

3. **Masalah JWT Token**
   - Regenerate JWT secret: `php artisan jwt:secret --force`
   - Clear cache: `php artisan cache:clear`

4. **Masalah Upload File**
   - Periksa izin direktori `storage/`
   - Verifikasi `storage:link` sudah dibuat dengan benar

## 📞 **SUMBER BANTUAN**

- **Support Domainesia**: [support.domainesia.com]
- **Dokumentasi Laravel**: [laravel.com/docs]
- **Repository Proyek**: Repository GitHub Anda

## 🎉 **CHECKLIST POST-DEPLOYMENT**

- [ ] Website memuat dengan benar
- [ ] Endpoint API merespons
- [ ] Koneksi database berfungsi
- [ ] Login admin berfungsi
- [ ] Aplikasi mobile terhubung ke API
- [ ] Upload file berfungsi
- [ ] Sertifikat SSL aktif
- [ ] Error logging diaktifkan

---

**Sistem manajemen absensi dan KPI Anda sekarang siap untuk digunakan di produksi!**

Butuh bantuan? Periksa bagian troubleshooting atau hubungi support Domainesia.