# 🚀 Production Deployment Guide - Domainesia Hosting

## 📁 Deployment Package Ready

Semua file backend Laravel telah disiapkan untuk hosting Domainesia di folder:
**`deployment/backend_production/`**

## 🎯 Langkah Deployment

### 1. **Upload ke Domainesia**
1. Login ke cPanel Domainesia Anda
2. Buka **File Manager** 
3. Masuk ke direktori `public_html`
4. Upload SEMUA isi folder `deployment/backend_production/` ke `public_html`

### 2. **Setup Database**
1. Di cPanel, buka **MySQL Databases**
2. Buat database baru (contoh: `namasite_attendance`)
3. Buat user database dengan hak akses penuh
4. Catat nama database, username, dan password

### 3. **Konfigurasi Environment**
1. Edit file `.env` di `public_html` melalui File Manager
2. Update pengaturan penting:
   ```
   APP_URL=https://namadomainanda.com
   
   DB_DATABASE=namasite_attendance
   DB_USERNAME=namasite_dbuser
   DB_PASSWORD=password_aman_anda
   ```

### 4. **Generate Key (Jika Terminal Tersedia)**
```bash
php artisan key:generate --force
php artisan jwt:secret --force
php artisan migrate --force
php artisan db:seed --force
```

### 5. **Update Aplikasi Mobile**
Copy file `deployment/mobile_config_production.dart` ke:
`mobile/lib/core/constants/api_constants.dart`

Ganti `https://yourdomain.com` dengan domain Anda yang sebenarnya.

## ✅ Test Deployment

- Buka website: `https://namadomainanda.com`
- Test API: `https://namadomainanda.com/api/test`
- Login admin untuk memastikan sistem berfungsi

## 🔒 Keamanan Penting

- Pastikan `APP_DEBUG=false` di production
- Gunakan HTTPS (SSL) untuk keamanan
- Jaga kerahasiaan file `.env`
- Backup database secara berkala

---

**Sistem attendance dan KPI management Anda siap untuk produksi!** 🎉

Butuh bantuan? Lihat file `DEPLOYMENT_INSTRUCTIONS.md` untuk panduan lengkap atau hubungi support Domainesia.