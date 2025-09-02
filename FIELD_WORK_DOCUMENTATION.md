# Field Work & Anti-Fake GPS Features

## Overview
Sistem absensi telah ditingkatkan dengan fitur deteksi kerja lapangan dan anti-manipulasi GPS untuk memastikan keakuratan data absensi, terutama untuk karyawan marketing yang bekerja di luar kantor.

## Features

### 1. Geo-Fence Detection
- **Radius Detection**: Otomatis mendeteksi apakah karyawan berada dalam radius kantor (default 100m)
- **Dynamic Form**: UI berubah berdasarkan lokasi (dalam/luar kantor)
- **Office Configuration**: Koordinat kantor dapat dikonfigurasi melalui file config

### 2. Field Work Validation
Ketika karyawan berada di luar area kantor, sistem akan memvalidasi:
- **Foto Wajib**: Foto selfie wajib diambil untuk verifikasi
- **Deskripsi Aktivitas**: Minimal 10 karakter, menjelaskan kegiatan yang dilakukan
- **Nama Klien/Lokasi**: Informasi klien atau lokasi yang dikunjungi
- **Work Type**: Otomatis ter-set sebagai "field_work"

### 3. Anti-Fake GPS Protection
Sistem mendeteksi indikasi manipulasi GPS:
- **Coordinate Precision Check**: Koordinat dengan presisi > 8 desimal dianggap mencurigakan
- **Teleportation Detection**: Mendeteksi pergerakan yang tidak wajar (kecepatan > 200 km/jam)
- **GPS Accuracy Validation**: Memvalidasi akurasi GPS dari device

## Configuration

### Backend Configuration (`config/attendance.php`)
```php
'office' => [
    'latitude' => -6.200000,     // Latitude kantor
    'longitude' => 106.816666,   // Longitude kantor  
    'radius' => 100,             // Radius kantor (meter)
    'name' => 'Kantor Pusat',
],

'field_work' => [
    'enable_geofence' => true,
    'mandatory_photo' => true,
    'mandatory_description' => true,
    'mandatory_client_name' => true,
    'min_description_length' => 10,
],

'anti_fake_gps' => [
    'enable_teleportation_detection' => true,
    'enable_precision_check' => true,
    'max_travel_speed' => 200,        // km/h
    'suspicious_precision_decimals' => 8,
]
```

### Mobile Configuration
Update koordinat kantor di `clock_in_out_screen.dart`:
```dart
// Office coordinates (replace with actual office coordinates)
double officeLatitude = -6.200000;  // Your office latitude
double officeLongitude = 106.816666; // Your office longitude
double officeRadius = 100; // 100 meters
```

## Database Schema

### Attendance Table Updates
```sql
ALTER TABLE attendances ADD COLUMN work_type VARCHAR(20) DEFAULT 'office';
ALTER TABLE attendances ADD COLUMN activity_description TEXT;
ALTER TABLE attendances ADD COLUMN client_name VARCHAR(255);
ALTER TABLE attendances ADD COLUMN notes TEXT;
```

## API Endpoints

### Clock In with Field Work
```http
POST /api/attendance/clock-in
Content-Type: multipart/form-data
Authorization: Bearer {token}

Fields:
- latitude (required): GPS latitude
- longitude (required): GPS longitude  
- address (optional): Address string
- photo (optional/required): Selfie photo file
- work_type (optional): 'office' or 'field_work'
- activity_description (required for field work): Activity description
- client_name (required for field work): Client or location name
- notes (optional): Additional notes
```

### Response Examples

#### Successful Field Work Clock In
```json
{
    "success": true,
    "data": {
        "id": 123,
        "user_id": 1,
        "date": "2024-01-15",
        "clock_in_time": "08:30:00",
        "work_type": "field_work",
        "activity_description": "Kunjungan klien untuk presentasi produk",
        "client_name": "PT ABC Indonesia",
        "clock_in_latitude": -6.250000,
        "clock_in_longitude": 106.850000
    },
    "message": "Clock in successful"
}
```

#### Validation Error for Field Work
```json
{
    "success": false,
    "message": "Foto selfie wajib untuk absensi di luar kantor"
}
```

#### Anti-Fake GPS Detection
```json
{
    "success": false,
    "message": "Koordinat GPS terdeteksi mencurigakan"
}
```

## Security Features

### 1. GPS Manipulation Detection
- **Precision Analysis**: Real GPS jarang memberikan koordinat > 6 desimal
- **Movement Speed**: Deteksi teleportation dengan kecepatan tidak wajar
- **Coordinate Validation**: Validasi format dan range koordinat

### 2. Photo Verification
- **Mandatory Upload**: Foto wajib untuk field work
- **File Validation**: Validasi format dan ukuran file
- **Metadata Preservation**: Menyimpan metadata foto untuk verifikasi

### 3. Activity Validation
- **Minimum Length**: Deskripsi aktivitas minimal 10 karakter
- **Required Fields**: Client name wajib untuk field work
- **Content Filtering**: Dapat ditambahkan filtering konten tidak pantas

## Testing

### Test Scenarios

1. **In-Office Clock In**
   - Koordinat dalam radius kantor
   - Form normal (foto opsional)
   - Work type: 'office'

2. **Field Work Clock In**
   - Koordinat di luar radius kantor
   - Form wajib (foto, deskripsi, klien)
   - Work type: 'field_work'

3. **Anti-Fake GPS Tests**
   - Koordinat dengan presisi tinggi (> 8 desimal)
   - Pergerakan cepat dari lokasi sebelumnya
   - Koordinat di luar range normal

### Manual Testing Commands
```bash
# Test normal office clock in
curl -X POST "http://localhost/absensi/backend/public/api/attendance/clock-in" \
  -H "Authorization: Bearer {token}" \
  -F "latitude=-6.200000" \
  -F "longitude=106.816666"

# Test field work (outside office)
curl -X POST "http://localhost/absensi/backend/public/api/attendance/clock-in" \
  -H "Authorization: Bearer {token}" \
  -F "latitude=-6.300000" \
  -F "longitude=106.900000" \
  -F "activity_description=Kunjungan klien ABC" \
  -F "client_name=PT ABC Indonesia" \
  -F "photo=@selfie.jpg"

# Test fake GPS (high precision)
curl -X POST "http://localhost/absensi/backend/public/api/attendance/clock-in" \
  -H "Authorization: Bearer {token}" \
  -F "latitude=-6.20000000000000001" \
  -F "longitude=106.81666600000000001"
```

## Monitoring & Analytics

### Field Work Analytics
- Persentase kerja lapangan vs kantor
- Lokasi kerja lapangan yang sering dikunjungi
- Waktu rata-rata di lokasi klien
- Aktivitas kerja lapangan terpopuler

### Security Monitoring
- Alert untuk detection fake GPS
- Log suspicious activities
- Analisis pattern absensi tidak normal
- Report karyawan dengan tingkat field work tinggi

## Troubleshooting

### Common Issues

1. **GPS Accuracy Low**
   - Ensure location services enabled
   - Wait for better GPS signal
   - Use high accuracy mode

2. **Form Not Showing for Field Work**
   - Check office coordinates configuration
   - Verify radius calculation
   - Debug distance calculation

3. **Photo Upload Fails**
   - Check file size limits
   - Verify image format (JPG, PNG)
   - Ensure sufficient storage space

### Debug Mode
Enable debug logging in `config/app.php`:
```php
'log_level' => 'debug',
```

Check logs for:
- Distance calculations
- GPS validation results
- Photo upload process
- Field work validation steps

## Future Enhancements

1. **ML-Based Detection**
   - Pattern recognition untuk behavior normal
   - Anomaly detection untuk suspicious activities
   - Image recognition untuk location verification

2. **Advanced Geofencing**
   - Multiple office locations
   - Client-specific geofences
   - Dynamic radius based on role

3. **Enhanced Security**
   - Device fingerprinting
   - Biometric verification
   - Blockchain-based attendance records

4. **Analytics Dashboard**
   - Real-time field work monitoring
   - Heatmap lokasi kerja lapangan
   - Productivity analytics per area
