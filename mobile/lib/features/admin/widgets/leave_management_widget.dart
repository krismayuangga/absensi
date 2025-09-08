import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';

class LeaveManagementWidget extends StatefulWidget {
  const LeaveManagementWidget({Key? key}) : super(key: key);

  @override
  State<LeaveManagementWidget> createState() => _LeaveManagementWidgetState();
}

class _LeaveManagementWidgetState extends State<LeaveManagementWidget> {
  String _selectedStatus = 'Semua';

  // Helper function to format date range
  String _formatDateRange(String startDate, String endDate) {
    try {
      // Handle different date formats from backend
      DateTime start, end;

      // Try parsing ISO format first (e.g., "2025-09-08T17:00:00.000000Z")
      if (startDate.contains('T')) {
        start = DateTime.parse(startDate);
        end = DateTime.parse(endDate);
      } else {
        // Parse simple date format (e.g., "2025-09-08")
        final DateFormat inputFormat = DateFormat('yyyy-MM-dd');
        start = inputFormat.parse(startDate);
        end = inputFormat.parse(endDate);
      }

      // Format without locale to avoid issues
      final List<String> months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];

      String formatDate(DateTime date) {
        return '${date.day} ${months[date.month]} ${date.year}';
      }

      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return formatDate(start);
      } else {
        return '${formatDate(start)} - ${formatDate(end)}';
      }
    } catch (e) {
      print('Error formatting date: $e');
      // Fallback: extract date part only if ISO format
      if (startDate.contains('T') && endDate.contains('T')) {
        final startDateOnly = startDate.split('T')[0];
        final endDateOnly = endDate.split('T')[0];
        return startDateOnly == endDateOnly
            ? startDateOnly
            : '$startDateOnly s/d $endDateOnly';
      }
      return startDate == endDate ? startDate : '$startDate s/d $endDate';
    }
  } // Helper function to format datetime

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Belum diketahui';

    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);

      // Format without locale to avoid issues
      final List<String> months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];

      final String formattedDate =
          '${dateTime.day} ${months[dateTime.month]} ${dateTime.year}';
      final String formattedTime =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

      return '$formattedDate, $formattedTime';
    } catch (e) {
      print('Error formatting datetime: $e');
      return dateTimeStr;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .loadLeaveRequests(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status Cuti',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Semua', 'Pending', 'Disetujui', 'Ditolak']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _filterLeaveRequests();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    Provider.of<AdminProvider>(context, listen: false)
                        .loadLeaveRequests(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Leave Requests List
        Expanded(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              if (adminProvider.isLoadingLeaves) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        adminProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            adminProvider.loadLeaveRequests(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final leaveRequests = adminProvider.leaveRequests;

              if (leaveRequests.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada pengajuan cuti',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pengajuan cuti dari karyawan akan muncul di sini',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => adminProvider.loadLeaveRequests(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaveRequests.length,
                  itemBuilder: (context, index) {
                    final leave = leaveRequests[index];
                    return _buildLeaveCard(leave, adminProvider);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveCard(
      Map<String, dynamic> leave, AdminProvider adminProvider) {
    final employeeName = leave['user']?['name'] ?? 'Unknown';
    final employeeId = leave['user']?['employee_id'] ?? 'N/A';
    final leaveType = leave['type_label'] ?? leave['type'] ?? 'Unknown';
    final startDate = leave['start_date'] ?? '';
    final endDate = leave['end_date'] ?? '';
    final status = leave['status'] ?? 'pending';
    final reason = leave['reason'] ?? '';
    final adminNotes = leave['manager_notes'] ?? '';
    final submittedAt = leave['created_at'] ?? '';

    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    employeeName.isNotEmpty
                        ? employeeName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: $employeeId',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Leave Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Jenis Cuti: $leaveType',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatDateRange(startDate, endDate),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Diajukan: ${_formatDateTime(submittedAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Alasan: $reason',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (adminNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.admin_panel_settings,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Catatan Admin: $adminNotes',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons for Pending Status
            if (status.toLowerCase() == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(
                          context, leave['id'], 'approved', adminProvider),
                      icon: const Icon(Icons.check),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(
                          context, leave['id'], 'rejected', adminProvider),
                      icon: const Icon(Icons.close),
                      label: const Text('Tolak'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Submitted date
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Diajukan: ${_formatDate(submittedAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _filterLeaveRequests() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.loadLeaveRequests(
      refresh: true,
      status: _selectedStatus == 'Semua' ? null : _selectedStatus.toLowerCase(),
    );
  }

  Future<void> _showApprovalDialog(BuildContext context, int leaveId,
      String action, AdminProvider adminProvider) async {
    final TextEditingController notesController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action == 'approved' ? 'Setujui Cuti' : 'Tolak Cuti'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action == 'approved'
                      ? 'Apakah Anda yakin ingin menyetujui pengajuan cuti ini?'
                      : 'Apakah Anda yakin ingin menolak pengajuan cuti ini?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Admin (opsional)',
                    border: OutlineInputBorder(),
                    hintText: 'Berikan catatan atau alasan...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    action == 'approved' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(action == 'approved' ? 'Setujui' : 'Tolak'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop();

                final success = await adminProvider.updateLeaveStatus(
                  leaveId,
                  action,
                  adminNotes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pengajuan cuti berhasil ${action == 'approved' ? 'disetujui' : 'ditolak'}',
                      ),
                      backgroundColor:
                          action == 'approved' ? Colors.green : Colors.red,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          adminProvider.errorMessage ?? 'Terjadi kesalahan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
