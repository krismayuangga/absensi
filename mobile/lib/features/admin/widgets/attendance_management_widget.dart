import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';

class AttendanceManagementWidget extends StatefulWidget {
  const AttendanceManagementWidget({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementWidget> createState() =>
      _AttendanceManagementWidgetState();
}

class _AttendanceManagementWidgetState
    extends State<AttendanceManagementWidget> {
  String _selectedDate = DateTime.now().toString().split(' ')[0];
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .loadAttendanceRecords(refresh: true);
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(_selectedDate),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        'Semua',
                        'Hadir',
                        'Tidak Hadir',
                        'Terlambat',
                        'Pulang Cepat'
                      ]
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                        _filterAttendance();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Attendance List
        Expanded(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              if (adminProvider.isLoadingAttendance) {
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
                            adminProvider.loadAttendanceRecords(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final attendanceRecords = adminProvider.attendanceRecords;

              if (attendanceRecords.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada data kehadiran',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Data kehadiran akan muncul setelah karyawan melakukan absensi',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    adminProvider.loadAttendanceRecords(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceRecords[index];
                    return _buildAttendanceCard(attendance);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> attendance) {
    final employeeName = attendance['user']?['name'] ?? 'Unknown';
    final employeeId = attendance['user']?['employee_id'] ?? 'N/A';
    final date = attendance['date'] ?? '';
    final clockIn = attendance['clock_in_time'] ?? '';
    final clockOut = attendance['clock_out_time'] ?? '';
    final status = attendance['status'] ?? 'Unknown';

    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
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
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo('Masuk', clockIn, Icons.login),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeInfo('Keluar',
                      clockOut.isEmpty ? '-' : clockOut, Icons.logout),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
      case 'present':
        return Colors.green;
      case 'terlambat':
      case 'late':
        return Colors.orange;
      case 'tidak hadir':
      case 'absent':
        return Colors.red;
      case 'pulang cepat':
      case 'early_leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked.toString().split(' ')[0];
      });
      _filterAttendance();
    }
  }

  void _filterAttendance() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.loadAttendanceRecords(
      refresh: true,
      date: _selectedDate,
      status: _selectedStatus == 'Semua' ? null : _selectedStatus,
    );
  }
}
