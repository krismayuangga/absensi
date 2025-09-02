# 📱 Attendance & KPI Management System with Field Work Detection

Modern attendance and KPI management 4. **Start Server**
```bash
php artisan serve
```

## ⚙️ Field Work Configuration

### Office Location Setup (config/attendance.php)
```php
'office' => [
    'latitude' => -6.200000,      // Your office latitude
    'longitude' => 106.816666,    // Your office longitude
    'radius' => 100,              // Office radius in meters
    'name' => 'Kantor Pusat',
],
```

### Field Work Validation
```php
'field_work' => [
    'enable_geofence' => true,
    'mandatory_photo' => true,
    'mandatory_description' => true,
    'mandatory_client_name' => true,
    'min_description_length' => 10,
],
```

### Anti-Fake GPS Security
```php
'anti_fake_gps' => [
    'enable_teleportation_detection' => true,
    'enable_precision_check' => true,
    'max_travel_speed' => 200,           // km/h
    'suspicious_precision_decimals' => 8,
],
```em built with Laravel backend API and Flutter mobile app, featuring advanced field work detection and anti-fake GPS protection.

## 🚀 Latest Features (Version 3.0)

### 🆕 Field Work Detection & Anti-Fake GPS
- **Geo-Fence Detection** - Automatic office/field work detection
- **Dynamic Forms** - Different UI based on location
- **Anti-GPS Manipulation** - Security against fake GPS apps
- **Mandatory Field Work Validation** - Photos and descriptions required
- **Teleportation Detection** - Impossible movement speed detection

### Core Features
- **Multi-tenant Support** - Support multiple companies
- **GPS-based Attendance** - Location validation for clock in/out
- **Face Recognition** - Photo capture for attendance verification
- **Real-time Dashboard** - Live attendance and KPI monitoring
- **KPI Management** - Comprehensive performance tracking
- **Leave Management** - Request and approval system
- **Role-based Access** - Different access levels (Admin, HR, Employee)

### Mobile App Features
- **Offline Capability** - Work without internet connection
- **Push Notifications** - Real-time updates
- **Biometric Login** - Fingerprint/Face ID support
- **Multi-language** - Indonesian and English support

## 🏗️ Tech Stack

### Backend
- **Laravel 10** - PHP Framework
- **MySQL** - Database
- **JWT Authentication** - Secure API authentication
- **Image Processing** - Avatar and photo handling
- **Pusher** - Real-time notifications

### Mobile App
- **Flutter** - Cross-platform mobile development
- **Provider/Riverpod** - State management
- **Dio** - HTTP client
- **Shared Preferences** - Local storage
- **Geolocator** - GPS functionality
- **Camera** - Photo capture

## 📱 Mobile App Setup

Navigate to the mobile directory and follow Flutter setup:

```bash
cd mobile
flutter pub get
flutter run
```

## 🗄️ Database Schema

The system includes the following main tables:

### Core Tables
- **companies** - Multi-tenant company data
- **users** - Employees and admin users
- **departments** - Company departments
- **positions** - Job positions
- **shifts** - Work shift schedules
- **locations** - Office locations for GPS validation

### Attendance Tables
- **attendances** - Daily attendance records
- **leaves** - Leave/permission requests

### KPI Tables
- **kpi_categories** - KPI categories (Productivity, Quality, etc.)
- **kpi_templates** - KPI templates by position
- **kpi_indicators** - Individual KPI metrics
- **user_kpis** - Employee KPI assignments
- **kpi_scores** - KPI performance scores

## 🔧 Backend Setup

1. **Install Dependencies**
```bash
cd backend
composer install
```

2. **Environment Setup**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. **Database Setup**
```bash
# Import the database schema
mysql -u root -p attendance_kpi < ../database/schema.sql

# Generate JWT secret
php artisan jwt:secret
```

4. **Storage Setup**
```bash
php artisan storage:link
```

5. **Start Server**
```bash
php artisan serve
```

## 📋 API Documentation

### Authentication Endpoints
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/auth/profile` - Get user profile
- `PUT /api/v1/auth/profile` - Update profile
- `POST /api/v1/auth/change-password` - Change password
- `POST /api/v1/auth/logout` - Logout
- `POST /api/v1/auth/refresh` - Refresh token

### Attendance Endpoints
- `GET /api/v1/attendance/today` - Get today's attendance
- `POST /api/v1/attendance/clock-in` - Clock in with field work support
  - **Parameters**: latitude, longitude, address, photo, work_type, activity_description, client_name
  - **Field Work**: Automatic detection when outside office radius
  - **Validation**: Mandatory photo and descriptions for field work
- `POST /api/v1/attendance/clock-out` - Clock out
- `GET /api/v1/attendance/history` - Attendance history

#### Field Work Clock-In Example
```bash
# Automatic field work detection when outside office
curl -X POST "http://localhost:8000/api/attendance/clock-in" \
  -H "Authorization: Bearer {token}" \
  -F "latitude=-6.300000" \
  -F "longitude=106.900000" \
  -F "activity_description=Client meeting at ABC Corp" \
  -F "client_name=PT ABC Indonesia" \
  -F "photo=@selfie.jpg"
```

### Leave Endpoints
- `GET /api/v1/leaves` - Get leave requests
- `POST /api/v1/leaves` - Submit leave request
- `PUT /api/v1/leaves/{id}` - Update leave request

### KPI Endpoints
- `GET /api/v1/kpi/dashboard` - KPI dashboard
- `GET /api/v1/kpi/my-kpis` - My KPI assignments
- `POST /api/v1/kpi/scores` - Update KPI scores

## 🔐 Security Features

- **JWT Authentication** - Secure token-based auth
- **Role-based Access Control** - Different permission levels
- **GPS Validation** - Location-based attendance
- **Photo Verification** - Image capture for attendance
- **Input Validation** - Server-side validation
- **SQL Injection Protection** - Laravel ORM protection

## 📊 Sample KPI Categories

The system comes with pre-configured KPI categories:

1. **Productivity (40%)** - Work output and efficiency
2. **Quality (30%)** - Work quality and accuracy
3. **Teamwork (20%)** - Collaboration and communication
4. **Initiative (10%)** - Innovation and proactive behavior

## 🎯 Default User Roles

- **Super Admin** - Full system access
- **Admin** - Company-level management
- **HR** - Employee and attendance management
- **Employee** - Basic attendance and KPI access

## 🧪 Testing

### Backend Testing
```bash
cd backend
php artisan test
```

### Mobile Testing
```bash
cd mobile
flutter test
```

## 🚀 Deployment

### Backend Deployment
1. Upload files to server
2. Configure web server (Apache/Nginx)
3. Set up database
4. Configure environment variables
5. Set proper file permissions

### Mobile App Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📞 Support

For support and questions, please contact the development team.

## 📄 License

This project is licensed under the MIT License.
