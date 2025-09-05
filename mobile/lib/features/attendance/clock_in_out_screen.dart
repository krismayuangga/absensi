import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../widgets/field_work_form.dart';

class ClockInOutScreen extends StatefulWidget {
  final bool isClockOut;

  const ClockInOutScreen({
    super.key,
    this.isClockOut = false,
  });

  @override
  State<ClockInOutScreen> createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  Position? _currentPosition;
  String? _currentAddress;
  File? _selectedImage;
  bool _isLoadingLocation = false;
  bool _isFieldWork = false;
  double _distanceFromOffice = 0.0;
  final ImagePicker _picker = ImagePicker();

  // Office coordinates - Kemang area, Jakarta Selatan
  static const double officeLatitude = -6.270075;
  static const double officeLongitude = 106.819858;
  static const double officeRadius = 200.0; // 200 meters - matched with backend

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Layanan lokasi tidak aktif. Silakan aktifkan GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Izin lokasi ditolak.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
            'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Calculate field work status
      _calculateFieldWorkStatus(position.latitude, position.longitude);
    } catch (e) {
      _showErrorDialog('Gagal mendapatkan lokasi: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _calculateFieldWorkStatus(double latitude, double longitude) {
    _distanceFromOffice = Geolocator.distanceBetween(
      latitude,
      longitude,
      officeLatitude,
      officeLongitude,
    );

    setState(() {
      _isFieldWork = _distanceFromOffice > officeRadius;
    });
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Alamat tidak dapat ditemukan';
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal mengambil foto: ${e.toString()}');
    }
  }

  Future<void> _handleClockAction() async {
    if (_currentPosition == null) {
      _showErrorDialog(
          'Lokasi belum tersedia. Silakan tunggu atau refresh lokasi.');
      return;
    }

    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    // Check if user is in office area (for clock in only)
    if (!widget.isClockOut) {
      await _checkOfficeLocationAndProceed(attendanceProvider);
    } else {
      // For clock out, proceed normally
      bool success = await attendanceProvider.clockOut(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _currentAddress,
        photo: _selectedImage,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
            attendanceProvider.errorMessage ?? 'Gagal melakukan absensi');
      }
    }
  }

  Future<void> _checkOfficeLocationAndProceed(
      AttendanceProvider attendanceProvider) async {
    // Use the calculated distance
    double distance = _distanceFromOffice;

    // If user is outside office area, show field work form
    if (distance > officeRadius) {
      _showFieldWorkForm(attendanceProvider);
    } else {
      // User is in office, proceed with normal clock in
      bool success = await attendanceProvider.clockIn(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _currentAddress,
        photo: _selectedImage,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
            attendanceProvider.errorMessage ?? 'Gagal melakukan absensi');
      }
    }
  }

  void _showFieldWorkForm(AttendanceProvider attendanceProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FieldWorkForm(
        onSubmit: (activityDescription, clientName, photo) async {
          Navigator.of(context).pop(); // Close dialog

          // Proceed with field work clock in
          bool success = await attendanceProvider.clockIn(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            address: _currentAddress,
            photo: photo ?? _selectedImage,
            workType: 'field_work',
            activityDescription: activityDescription,
            clientName: clientName,
          );

          if (success) {
            _showSuccessDialog();
          } else {
            _showErrorDialog(
                attendanceProvider.errorMessage ?? 'Gagal melakukan absensi');
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Berhasil',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        content: Text(
          widget.isClockOut
              ? 'Absen pulang berhasil!'
              : 'Absen masuk berhasil!',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.isClockOut ? 'Absen Pulang' : 'Absen Masuk',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Time Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isClockOut ? Icons.logout : Icons.login,
                    size: 48.w,
                    color: widget.isClockOut ? Colors.orange : Colors.green,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    TimeOfDay.now().format(context),
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatCurrentDate(),
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Work Status Card
            if (_currentPosition != null && !widget.isClockOut)
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isFieldWork
                        ? [Colors.orange.shade50, Colors.orange.shade100]
                        : [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _isFieldWork
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isFieldWork ? Colors.orange : Colors.green)
                          .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: _isFieldWork
                            ? Colors.orange.shade200
                            : Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _isFieldWork ? Icons.location_city : Icons.domain,
                        color: _isFieldWork
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isFieldWork ? 'Kerja Lapangan' : 'Kerja Kantor',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: _isFieldWork
                                  ? Colors.orange.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _isFieldWork
                                ? 'Anda berada ${_distanceFromOffice.toStringAsFixed(0)}m dari kantor'
                                : 'Anda berada di area kantor',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: _isFieldWork
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                          if (_isFieldWork)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'Form tambahan diperlukan',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      _isFieldWork
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      color: _isFieldWork
                          ? Colors.orange.shade600
                          : Colors.green.shade600,
                      size: 28.w,
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24.h),

            // Location Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 24.w,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Lokasi Saat Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (_isLoadingLocation)
                    Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Mendapatkan lokasi...',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else if (_currentAddress != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentAddress!,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (_currentPosition != null)
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                            'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      'Lokasi tidak tersedia',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 12.h),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: Icon(Icons.refresh, size: 16.w),
                    label: Text(
                      'Refresh Lokasi',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Photo Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 24.w,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Foto Selfie (Opsional)',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (_selectedImage != null)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: Icon(
                      _selectedImage != null
                          ? Icons.camera_alt
                          : Icons.camera_alt_outlined,
                      size: 20.w,
                    ),
                    label: Text(
                      _selectedImage != null ? 'Ganti Foto' : 'Ambil Foto',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Submit Button
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, child) {
                return PrimaryButton(
                  text: widget.isClockOut ? 'Absen Pulang' : 'Absen Masuk',
                  onPressed:
                      attendanceProvider.isLoading || _currentPosition == null
                          ? null
                          : _handleClockAction,
                  isLoading: attendanceProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}
