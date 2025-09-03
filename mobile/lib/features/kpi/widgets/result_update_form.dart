import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/kpi_provider.dart';

class ResultUpdateForm extends StatefulWidget {
  final Map<String, dynamic> visit;

  const ResultUpdateForm({
    super.key,
    required this.visit,
  });

  @override
  State<ResultUpdateForm> createState() => _ResultUpdateFormState();
}

class _ResultUpdateFormState extends State<ResultUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _resultNotesController = TextEditingController();
  final _potentialValueController = TextEditingController();

  String _selectedResult = 'pending';
  String _selectedNextAction = 'follow_up';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Pre-populate form if visit has existing result
    final visit = widget.visit;
    _selectedResult = visit['result_status'] ?? 'pending';
    _resultNotesController.text = visit['result_notes'] ?? '';
    _potentialValueController.text = visit['potential_value']?.toString() ?? '';
    _selectedNextAction = visit['next_action'] ?? 'follow_up';
  }

  @override
  void dispose() {
    _resultNotesController.dispose();
    _potentialValueController.dispose();
    super.dispose();
  }

  // Helper method for safe int parsing
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final kpiProvider = Provider.of<KPIProvider>(context, listen: false);
    final visitId = _safeParseInt(widget.visit['id']);
    final clientName = widget.visit['client_name'] ?? '';

    bool success;

    try {
      if (visitId <= 0) {
        // Untuk prospek baru, buat visit baru terlebih dahulu
        success = await kpiProvider.logVisit(
          clientName: clientName,
          visitPurpose: 'Follow Up Prospek',
          latitude: 0.0,
          longitude: 0.0,
          address: 'Alamat tidak tersedia',
          notes: _resultNotesController.text.isNotEmpty
              ? 'Status: $_selectedResult\nCatatan: ${_resultNotesController.text}'
              : 'Status: $_selectedResult',
          photo: null,
        );
      } else {
        // Update visit yang sudah ada
        success = await kpiProvider.updateVisitResult(
          visitId: visitId,
          status: _selectedResult,
          potentialValue: _potentialValueController.text.isNotEmpty
              ? double.tryParse(_potentialValueController.text)
              : null,
          nextAction: _selectedNextAction,
          endTime: DateTime.now(),
        );
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                visitId <= 0
                    ? 'Prospek berhasil dibuat!'
                    : 'Hasil kunjungan berhasil diupdate!',
              ),
              backgroundColor: const Color(0xFF4A9B8E),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kpiProvider.errorMessage ?? 'Gagal menyimpan data',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getResultColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'potential':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      case 'potential':
        return Icons.schedule;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A9B8E),
        elevation: 0,
        title: Text(
          'Update Hasil Kunjungan',
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
                  // Visit Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                                size: 20.w,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visit['client_name'] ??
                                        'Klien Tidak Dikenal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    KPIProvider.getVisitPurposeLabel(
                                        visit['visit_purpose'] ??
                                            'prospecting'),
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.9),
                              size: 16.w,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              visit['visited_at'] ?? 'Waktu tidak diketahui',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Current Status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color:
                          _getResultColor(visit['result_status'] ?? 'pending')
                              .withOpacity(0.1),
                      border: Border.all(
                        color:
                            _getResultColor(visit['result_status'] ?? 'pending')
                                .withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getResultIcon(visit['result_status'] ?? 'pending'),
                          color: _getResultColor(
                              visit['result_status'] ?? 'pending'),
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Saat Ini',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                KPIProvider.getResultStatusLabel(
                                    visit['result_status'] ?? 'pending'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getResultColor(
                                      visit['result_status'] ?? 'pending'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Result Form
                  Text(
                    'Update Hasil Kunjungan',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Result Status
                  DropdownButtonFormField<String>(
                    value: _selectedResult,
                    decoration: InputDecoration(
                      labelText: 'Status Hasil *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: Icon(_getResultIcon(_selectedResult)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: KPIProvider.getResultStatusOptions()
                        .map((status) => DropdownMenuItem(
                              value: status['value'],
                              child: Row(
                                children: [
                                  Icon(
                                    _getResultIcon(status['value']!),
                                    color: _getResultColor(status['value']!),
                                    size: 20.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(status['label']!),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedResult = value!;
                      });
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Potential Value (if success or potential)
                  if (_selectedResult == 'success' ||
                      _selectedResult == 'potential')
                    Column(
                      children: [
                        TextFormField(
                          controller: _potentialValueController,
                          decoration: InputDecoration(
                            labelText: 'Nilai Potensial (Rp)',
                            hintText: 'Contoh: 5000000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),

                  // Result Notes
                  TextFormField(
                    controller: _resultNotesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan Hasil *',
                      hintText:
                          'Jelaskan hasil kunjungan dan tindak lanjut yang diperlukan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.note_alt),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      // Catatan tidak wajib, bisa kosong
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Next Action
                  DropdownButtonFormField<String>(
                    value: _selectedNextAction,
                    decoration: InputDecoration(
                      labelText: 'Tindak Lanjut *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.next_plan),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: KPIProvider.getNextActionOptions()
                        .map((action) => DropdownMenuItem(
                              value: action['value'],
                              child: Text(action['label']!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNextAction = value!;
                      });
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: kpiProvider.isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9B8E),
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
                              'Update Hasil',
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
