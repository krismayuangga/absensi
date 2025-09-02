import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../../core/providers/leave_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_overlay.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String _selectedLeaveType = 'annual';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDay = false;
  String? _halfDayPeriod;
  File? _attachmentFile;

  final _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _leaveTypes = [
    {
      'value': 'annual',
      'label': 'Cuti Tahunan',
      'icon': Icons.beach_access,
      'color': Colors.blue
    },
    {
      'value': 'sick',
      'label': 'Cuti Sakit',
      'icon': Icons.local_hospital,
      'color': Colors.red
    },
    {
      'value': 'maternity',
      'label': 'Cuti Melahirkan',
      'icon': Icons.child_care,
      'color': Colors.pink
    },
    {
      'value': 'paternity',
      'label': 'Cuti Ayah',
      'icon': Icons.family_restroom,
      'color': Colors.indigo
    },
    {
      'value': 'personal',
      'label': 'Cuti Pribadi',
      'icon': Icons.person,
      'color': Colors.green
    },
    {
      'value': 'emergency',
      'label': 'Cuti Darurat',
      'icon': Icons.warning,
      'color': Colors.orange
    },
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ajukan Cuti',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: LoadingOverlay(
        isLoading: context.watch<LeaveProvider>().isLoading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header gradient
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      Colors.grey[50]!,
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Type Selection
                      _buildSectionTitle('Jenis Cuti'),
                      const SizedBox(height: 16),
                      _buildLeaveTypeSelector(),

                      const SizedBox(height: 32),

                      // Date Selection
                      _buildSectionTitle('Periode Cuti'),
                      const SizedBox(height: 16),
                      _buildDateSelector(),

                      const SizedBox(height: 24),

                      // Half Day Option
                      _buildHalfDayOption(),

                      const SizedBox(height: 32),

                      // Reason
                      _buildSectionTitle('Alasan Cuti'),
                      const SizedBox(height: 16),
                      _buildReasonField(),

                      const SizedBox(height: 32),

                      // Attachment
                      _buildSectionTitle('Lampiran (Opsional)'),
                      const SizedBox(height: 16),
                      _buildAttachmentSection(),

                      const SizedBox(height: 32),

                      // Summary Card
                      _buildSummaryCard(),

                      const SizedBox(height: 32),

                      // Submit Button
                      CustomButton(
                        text: 'Ajukan Cuti',
                        onPressed: _submitLeaveRequest,
                        width: double.infinity,
                        height: 56,
                        backgroundColor: AppColors.primary,
                        icon: Icons.send,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildLeaveTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _leaveTypes.map((type) {
          final isSelected = _selectedLeaveType == type['value'];
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? type['color'].withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? type['color'] : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type['icon'],
                  color: type['color'],
                  size: 24,
                ),
              ),
              title: Text(
                type['label'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? type['color'] : Colors.grey[800],
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: type['color'])
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () {
                setState(() {
                  _selectedLeaveType = type['value'];
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Tanggal Mulai',
                  date: _startDate,
                  onTap: () => _selectStartDate(),
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateButton(
                  label: 'Tanggal Selesai',
                  date: _endDate,
                  onTap: () => _selectEndDate(),
                  icon: Icons.event,
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Durasi: ${_calculateDays()} hari',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: date != null
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: date != null ? AppColors.primary : Colors.grey[400],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Pilih tanggal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: date != null ? AppColors.primary : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfDayOption() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _isHalfDay,
                onChanged: (value) {
                  setState(() {
                    _isHalfDay = value ?? false;
                    if (!_isHalfDay) {
                      _halfDayPeriod = null;
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Cuti Setengah Hari',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          if (_isHalfDay) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Pagi'),
                    value: 'morning',
                    groupValue: _halfDayPeriod,
                    onChanged: (value) {
                      setState(() {
                        _halfDayPeriod = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Siang'),
                    value: 'afternoon',
                    groupValue: _halfDayPeriod,
                    onChanged: (value) {
                      setState(() {
                        _halfDayPeriod = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextField(
        controller: _reasonController,
        labelText: 'Alasan pengajuan cuti',
        hintText: 'Jelaskan alasan Anda mengajukan cuti...',
        maxLines: 4,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Alasan cuti harus diisi';
          }
          if (value.trim().length < 10) {
            return 'Alasan minimal 10 karakter';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attachmentFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachmentFile!.path.split('/').last,
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _attachmentFile = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload dokumen pendukung (surat dokter, undangan, dll)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_startDate == null || _endDate == null || _selectedLeaveType.isEmpty) {
      return const SizedBox.shrink();
    }

    final leaveType = _leaveTypes.firstWhere(
      (type) => type['value'] == _selectedLeaveType,
      orElse: () => _leaveTypes.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Pengajuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Jenis Cuti', leaveType['label']),
          _buildSummaryRow('Periode',
              '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
          _buildSummaryRow('Durasi', '${_calculateDays()} hari'),
          if (_isHalfDay && _halfDayPeriod != null)
            _buildSummaryRow('Periode Setengah Hari',
                _halfDayPeriod == 'morning' ? 'Pagi' : 'Siang'),
          if (_attachmentFile != null) _buildSummaryRow('Lampiran', 'Ada'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _pickFile(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _attachmentFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai dan selesai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isHalfDay && _halfDayPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih periode setengah hari'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final leaveProvider = context.read<LeaveProvider>();

      final success = await leaveProvider.submitLeaveRequest(
        type: _selectedLeaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        isHalfDay: _isHalfDay,
        halfDayPeriod: _halfDayPeriod,
        attachment: _attachmentFile,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengajuan cuti berhasil dikirim'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(leaveProvider.error ?? 'Gagal mengirim pengajuan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
