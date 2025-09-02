import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/kpi_provider.dart';

class ExportDataDialog extends StatefulWidget {
  const ExportDataDialog({super.key});

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  String _selectedFormat = 'csv';
  String _selectedPeriod = 'month';
  bool _includeImages = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Export Data KPI',
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Format File',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _selectedFormat,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            items: const [
              DropdownMenuItem(value: 'csv', child: Text('CSV')),
              DropdownMenuItem(value: 'json', child: Text('JSON')),
              DropdownMenuItem(value: 'pdf', child: Text('PDF Report')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Periode Data',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _selectedPeriod,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            items: const [
              DropdownMenuItem(value: 'week', child: Text('Minggu Ini')),
              DropdownMenuItem(value: 'month', child: Text('Bulan Ini')),
              DropdownMenuItem(value: 'quarter', child: Text('Kuartal Ini')),
              DropdownMenuItem(value: 'year', child: Text('Tahun Ini')),
              DropdownMenuItem(value: 'all', child: Text('Semua Data')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPeriod = value!;
              });
            },
          ),
          SizedBox(height: 16.h),
          CheckboxListTile(
            title: Text(
              'Sertakan Foto',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            subtitle: Text(
              'Akan memperbesar ukuran file',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            value: _includeImages,
            onChanged: (value) {
              setState(() {
                _includeImages = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: _isExporting
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final kpiProvider = Provider.of<KPIProvider>(context, listen: false);

      // Load data for selected period
      await kpiProvider.loadReportData(_selectedPeriod);

      String fileContent;
      String fileName;
      String mimeType;

      switch (_selectedFormat) {
        case 'csv':
          fileContent = _generateCSV(kpiProvider);
          fileName =
              'kpi_data_${_selectedPeriod}_${DateTime.now().millisecondsSinceEpoch}.csv';
          mimeType = 'text/csv';
          break;
        case 'json':
          fileContent = _generateJSON(kpiProvider);
          fileName =
              'kpi_data_${_selectedPeriod}_${DateTime.now().millisecondsSinceEpoch}.json';
          mimeType = 'application/json';
          break;
        case 'pdf':
          // For PDF, we'll create a simple text-based report
          fileContent = _generatePDFContent(kpiProvider);
          fileName =
              'kpi_report_${_selectedPeriod}_${DateTime.now().millisecondsSinceEpoch}.txt';
          mimeType = 'text/plain';
          break;
        default:
          throw Exception('Format tidak didukung');
      }

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(fileContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Data KPI Export - ${_getPeriodLabel()}',
        text:
            'Data KPI telah berhasil di-export. Format: ${_selectedFormat.toUpperCase()}',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil di-export!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _generateCSV(KPIProvider kpiProvider) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'Tanggal,Nama Klien,Tujuan Kunjungan,Status Hasil,Alamat,Catatan,Nilai Potensi,Latitude,Longitude');

    // CSV Data
    for (final visit in kpiProvider.visitHistory) {
      final row = [
        visit['visited_at'] ?? '',
        _escapeCsvValue(visit['client_name'] ?? ''),
        KPIProvider.getVisitPurposeLabel(
            visit['visit_purpose'] ?? 'prospecting'),
        KPIProvider.getResultStatusLabel(visit['result_status'] ?? 'pending'),
        _escapeCsvValue(visit['address'] ?? ''),
        _escapeCsvValue(visit['notes'] ?? ''),
        visit['potential_value']?.toString() ?? '0',
        visit['latitude']?.toString() ?? '',
        visit['longitude']?.toString() ?? '',
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  String _generateJSON(KPIProvider kpiProvider) {
    final data = {
      'export_info': {
        'period': _selectedPeriod,
        'period_label': _getPeriodLabel(),
        'export_date': DateTime.now().toIso8601String(),
        'format': 'json',
        'include_images': _includeImages,
      },
      'summary': {
        'total_visits': kpiProvider.monthVisits,
        'today_visits': kpiProvider.todayVisits,
        'week_visits': kpiProvider.weekVisits,
        'success_rate': kpiProvider.successRate,
        'potential_value': kpiProvider.potentialValue,
        'formatted_potential_value': kpiProvider.formattedPotentialValue,
      },
      'visits': kpiProvider.visitHistory
          .map((visit) => {
                'id': visit['id'],
                'visited_at': visit['visited_at'],
                'client_name': visit['client_name'],
                'visit_purpose': visit['visit_purpose'],
                'visit_purpose_label': KPIProvider.getVisitPurposeLabel(
                    visit['visit_purpose'] ?? 'prospecting'),
                'result_status': visit['result_status'],
                'result_status_label': KPIProvider.getResultStatusLabel(
                    visit['result_status'] ?? 'pending'),
                'address': visit['address'],
                'notes': visit['notes'],
                'potential_value': visit['potential_value'],
                'latitude': visit['latitude'],
                'longitude': visit['longitude'],
                'photo_path': _includeImages ? visit['photo_path'] : null,
                'created_at': visit['created_at'],
                'updated_at': visit['updated_at'],
              })
          .toList(),
      'pending_visits': kpiProvider.pendingVisits
          .map((visit) => {
                'id': visit['id'],
                'client_name': visit['client_name'],
                'visit_purpose': visit['visit_purpose'],
                'visited_at': visit['visited_at'],
                'address': visit['address'],
                'notes': visit['notes'],
                'latitude': visit['latitude'],
                'longitude': visit['longitude'],
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _generatePDFContent(KPIProvider kpiProvider) {
    final buffer = StringBuffer();

    buffer.writeln('=== LAPORAN KPI ===');
    buffer.writeln('Periode: ${_getPeriodLabel()}');
    buffer.writeln('Tanggal Export: ${DateTime.now().toString()}');
    buffer.writeln('');

    buffer.writeln('=== RINGKASAN ===');
    buffer.writeln('Total Kunjungan: ${kpiProvider.monthVisits}');
    buffer.writeln('Kunjungan Hari Ini: ${kpiProvider.todayVisits}');
    buffer.writeln('Kunjungan Minggu Ini: ${kpiProvider.weekVisits}');
    buffer.writeln('Success Rate: ${kpiProvider.getFormattedSuccessRate()}');
    buffer.writeln('Potensi Nilai: ${kpiProvider.formattedPotentialValue}');
    buffer.writeln('');

    buffer.writeln('=== DETAIL KUNJUNGAN ===');
    for (int i = 0; i < kpiProvider.visitHistory.length; i++) {
      final visit = kpiProvider.visitHistory[i];
      buffer.writeln('${i + 1}. ${visit['client_name'] ?? 'Unknown Client'}');
      buffer.writeln('   Tanggal: ${visit['visited_at'] ?? 'N/A'}');
      buffer.writeln(
          '   Tujuan: ${KPIProvider.getVisitPurposeLabel(visit['visit_purpose'] ?? 'prospecting')}');
      buffer.writeln(
          '   Status: ${KPIProvider.getResultStatusLabel(visit['result_status'] ?? 'pending')}');
      buffer.writeln('   Alamat: ${visit['address'] ?? 'N/A'}');
      if (visit['potential_value'] != null && visit['potential_value'] > 0) {
        buffer.writeln(
            '   Potensi Nilai: Rp ${_formatCurrency(visit['potential_value'])}');
      }
      if (visit['notes'] != null && visit['notes'].isNotEmpty) {
        buffer.writeln('   Catatan: ${visit['notes']}');
      }
      buffer.writeln('');
    }

    buffer.writeln('=== KUNJUNGAN PENDING ===');
    if (kpiProvider.pendingVisits.isEmpty) {
      buffer.writeln('Tidak ada kunjungan pending.');
    } else {
      for (int i = 0; i < kpiProvider.pendingVisits.length; i++) {
        final visit = kpiProvider.pendingVisits[i];
        buffer.writeln('${i + 1}. ${visit['client_name'] ?? 'Unknown Client'}');
        buffer.writeln('   Tanggal: ${visit['visited_at'] ?? 'N/A'}');
        buffer.writeln(
            '   Tujuan: ${KPIProvider.getVisitPurposeLabel(visit['visit_purpose'] ?? 'prospecting')}');
        buffer.writeln('   Alamat: ${visit['address'] ?? 'N/A'}');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Minggu Ini';
      case 'month':
        return 'Bulan Ini';
      case 'quarter':
        return 'Kuartal Ini';
      case 'year':
        return 'Tahun Ini';
      case 'all':
        return 'Semua Data';
      default:
        return 'Unknown Period';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
