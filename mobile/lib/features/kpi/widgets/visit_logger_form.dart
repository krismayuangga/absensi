import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/kpi_provider.dart';

class VisitLoggerForm extends StatefulWidget {
  const VisitLoggerForm({super.key});

  @override
  State<VisitLoggerForm> createState() => _VisitLoggerFormState();
}

class _VisitLoggerFormState extends State<VisitLoggerForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  String _selectedPurpose = 'prospecting';
  XFile? _selectedPhoto;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi tidak aktif';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lokasi belum terdeteksi, silakan tunggu atau refresh')),
      );
      return;
    }

    try {
      final kpiProvider = Provider.of<KPIProvider>(context, listen: false);

      final success = await kpiProvider.logVisit(
        clientName: _clientNameController.text.trim(),
        visitPurpose: _selectedPurpose,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        photo: _selectedPhoto,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kunjungan berhasil dicatat!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(kpiProvider.errorMessage ?? 'Gagal mencatat kunjungan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error for debugging
        String errorMsg = 'Error: $e';
        if (e.toString().contains('String is not a subtype')) {
          errorMsg =
              'Data type error in form fields. Please check all dropdown selections.';
        } else if (e.toString().contains('FormatException')) {
          errorMsg =
              'Invalid data format. Please check location and form data.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: Text(
          'Catat Kunjungan',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Consumer<KPIProvider>(
        builder: (context, kpiProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Status Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _currentPosition != null
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.orange.shade400, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _currentPosition != null
                                ? Icons.location_on
                                : Icons.location_searching,
                            color: _currentPosition != null
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                            size: 20.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPosition != null
                                    ? 'Lokasi Terdeteksi'
                                    : _isGettingLocation
                                        ? 'Mencari Lokasi...'
                                        : 'Lokasi Belum Terdeteksi',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (_currentPosition != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!_isGettingLocation)
                          IconButton(
                            onPressed: _getCurrentLocation,
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Form Fields
                  Text(
                    'Informasi Kunjungan',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Client Name
                  TextFormField(
                    controller: _clientNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Klien/Prospek *',
                      hintText: 'Masukkan nama klien',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama klien wajib diisi';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Visit Purpose
                  DropdownButtonFormField<String>(
                    value: _selectedPurpose,
                    decoration: InputDecoration(
                      labelText: 'Tujuan Kunjungan *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: KPIProvider.getVisitPurposeOptions()
                        .map<DropdownMenuItem<String>>(
                            (purpose) => DropdownMenuItem<String>(
                                  value: purpose['value']!,
                                  child: Text(purpose['label']!),
                                ))
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedPurpose = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tujuan kunjungan wajib dipilih';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      hintText: 'Masukkan alamat lokasi kunjungan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 2,
                  ),

                  SizedBox(height: 16.h),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      hintText: 'Catatan tambahan tentang kunjungan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.note),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),

                  SizedBox(height: 20.h),

                  // Photo Section
                  Text(
                    'Foto Lokasi (Opsional)',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Container(
                    width: double.infinity,
                    height: 120.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                    ),
                    child: _selectedPhoto == null
                        ? InkWell(
                            onTap: _pickPhoto,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: 32.w, color: Colors.grey.shade600),
                                SizedBox(height: 8.h),
                                Text(
                                  'Ambil Foto Lokasi',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  File(_selectedPhoto!.path),
                                  width: double.infinity,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: InkWell(
                                  onTap: _pickPhoto,
                                  child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: kpiProvider.isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: kpiProvider.isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Catat Kunjungan',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
