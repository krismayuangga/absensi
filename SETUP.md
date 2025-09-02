# 🚀 Setup Instructions - Attendance & KPI System

## Prerequisites

Sebelum menjalankan project, pastikan sudah menginstall:

### Required Software:
- **Flutter SDK** ✅ (Already installed - Flutter 3.32.6)
- **PHP 8.0+** ⚠️ (Not installed yet)
- **Composer** ⚠️ (Not installed yet) 
- **MySQL/MariaDB** ⚠️ (Not installed yet)
- **VS Code** ✅ (Already installed)

## 📋 Step-by-Step Setup

### 1. Install PHP & Composer (Windows)

#### Option A: Using XAMPP (Recommended for beginners)
1. Download XAMPP dari https://www.apachefriends.org/download.html
2. Install XAMPP dengan PHP 8.0+
3. Start Apache dan MySQL dari XAMPP Control Panel
4. Download Composer dari https://getcomposer.org/download/

#### Option B: Manual Installation
1. Download PHP 8.0+ dari https://windows.php.net/download
2. Extract ke `C:\php\`
3. Add `C:\php\` ke System PATH
4. Download dan install Composer dari https://getcomposer.org/

### 2. Database Setup

```sql
-- 1. Buat database
CREATE DATABASE attendance_kpi;

-- 2. Import schema
-- Jalankan file: database/schema.sql
```

### 3. Backend Setup (Laravel API)

```bash
cd backend
composer install
cp .env.example .env
```

Edit file `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=attendance_kpi
DB_USERNAME=root
DB_PASSWORD=your_password

JWT_SECRET=your_jwt_secret_here
```

Generate application key:
```bash
php artisan key:generate
php artisan jwt:secret
```

Start Laravel server:
```bash
php artisan serve
```

### 4. Mobile Setup (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

## 🎯 Available VS Code Tasks

Gunakan `Ctrl+Shift+P` → "Tasks: Run Task":

- **Flutter: Run Mobile App** - Jalankan aplikasi mobile
- **Flutter: Build APK** - Build APK debug
- **PHP: Serve Backend** - Start Laravel server
- **Composer: Install Backend Dependencies** - Install PHP packages

## 🔐 Default Login

Setelah database di-setup, gunakan:
- **Email**: `admin@techinnovation.com`
- **Password**: `password`

## 📱 Testing Mobile App

Untuk test mobile app tanpa backend:
1. Jalankan Flutter app: `flutter run`
2. Pilih device (Android Emulator/Physical device)
3. App akan buka dengan splash screen

## 🌐 API Endpoints

Backend akan running di: `http://localhost:8000`

Key endpoints:
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/profile` - Get profile
- `POST /api/v1/attendance/clock-in` - Clock in
- `GET /api/v1/kpi/dashboard` - KPI dashboard

## 🛠️ Development Mode

### Backend Development:
- File changes akan auto-reload
- Check logs di terminal
- API testing dengan Postman/Thunder Client

### Mobile Development:
- Hot reload dengan `r` di terminal
- Hot restart dengan `R`
- Debug dengan breakpoints

## 📂 Project Structure

```
attendance-kpi/
├── backend/           # Laravel API
│   ├── app/          # Controllers, Models
│   ├── routes/       # API routes
│   └── database/     # Migrations
├── mobile/           # Flutter App
│   ├── lib/          # Dart source code
│   │   ├── core/     # Config, services, providers
│   │   └── features/ # UI screens
│   └── assets/       # Images, icons
└── database/         # SQL schema
```

## 🚀 Next Development Steps

1. **Complete Authentication Flow**
   - Login screen
   - Registration
   - Profile management

2. **Attendance Features**
   - GPS-based clock in/out
   - Photo capture
   - History tracking

3. **KPI Dashboard**
   - Performance charts
   - Score tracking
   - Leaderboard

## 📞 Need Help?

Jika ada masalah setup:
1. Check VS Code Problems panel
2. Check terminal output untuk error messages
3. Pastikan semua prerequisites sudah terinstall
4. Restart VS Code jika diperlukan

## 🎉 Ready to Code!

Setelah setup selesai, project siap untuk development! 
Start dengan task "Flutter: Run Mobile App" untuk test aplikasi mobile.
