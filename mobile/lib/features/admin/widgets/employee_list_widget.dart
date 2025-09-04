import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class EmployeeListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> employees;
  final Map<String, dynamic>? employeeStats;
  final Future<void> Function() onRefresh;
  final Future<bool> Function(Map<String, dynamic> employeeData)
      onCreateEmployee;
  final Future<bool> Function(
      String employeeId, Map<String, dynamic> employeeData) onUpdateEmployee;
  final Future<bool> Function(String employeeId) onDeleteEmployee;

  const EmployeeListWidget({
    super.key,
    required this.employees,
    required this.employeeStats,
    required this.onRefresh,
    required this.onCreateEmployee,
    required this.onUpdateEmployee,
    required this.onDeleteEmployee,
  });

  @override
  State<EmployeeListWidget> createState() => _EmployeeListWidgetState();
}

class _EmployeeListWidgetState extends State<EmployeeListWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredEmployees {
    if (_searchQuery.isEmpty) {
      return widget.employees;
    }

    return widget.employees.where((employee) {
      final name = employee['name']?.toString().toLowerCase() ?? '';
      final email = employee['email']?.toString().toLowerCase() ?? '';
      final nip = employee['nip']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          nip.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          // Header with stats and search
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                // Stats row
                if (widget.employeeStats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          '${widget.employeeStats!['total'] ?? 0}',
                          Colors.blue,
                          Icons.people,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          'Aktif',
                          '${widget.employeeStats!['active'] ?? 0}',
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          'Nonaktif',
                          '${widget.employeeStats!['inactive'] ?? 0}',
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],

                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari karyawan...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Employee list
          Expanded(
            child: filteredEmployees.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return _buildEmployeeCard(employee);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.w,
            color: color,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final isActive =
        employee['is_active'] == true || employee['is_active'] == 1;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: employee['photo'] != null
                      ? NetworkImage(employee['photo'])
                      : null,
                  child: employee['photo'] == null
                      ? Text(
                          _getInitials(employee['name'] ?? ''),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),

                SizedBox(width: 12.w),

                // Employee info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee['name'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Nonaktif',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        employee['nip'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (employee['position'] != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          employee['position'],
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action buttons
                PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handleEmployeeAction(action, employee),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('Lihat Detail'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Contact info
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: 14.w,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    employee['email'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),

            if (employee['phone'] != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14.w,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    employee['phone'],
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Karyawan tidak ditemukan'
                : 'Belum ada karyawan',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Coba dengan kata kunci lain'
                : 'Tambah karyawan baru untuk memulai',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Show add employee dialog
              _showAddEmployeeDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Karyawan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1)
      return nameParts[0].substring(0, 1).toUpperCase();
    return '${nameParts[0].substring(0, 1)}${nameParts[1].substring(0, 1)}'
        .toUpperCase();
  }

  void _handleEmployeeAction(String action, Map<String, dynamic> employee) {
    switch (action) {
      case 'view':
        _showEmployeeDetail(employee);
        break;
      case 'edit':
        _showEditEmployeeDialog(employee);
        break;
      case 'delete':
        _showDeleteConfirmation(employee);
        break;
    }
  }

  void _showEmployeeDetail(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detail Karyawan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama', employee['name'] ?? ''),
            _buildDetailRow('NIP', employee['nip'] ?? ''),
            _buildDetailRow('Email', employee['email'] ?? ''),
            _buildDetailRow('Telepon', employee['phone'] ?? ''),
            _buildDetailRow('Jabatan', employee['position'] ?? ''),
            _buildDetailRow(
                'Status', employee['is_active'] == true ? 'Aktif' : 'Nonaktif'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(': ', style: GoogleFonts.inter(fontSize: 12.sp)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    // TODO: Implement add employee dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fitur tambah karyawan akan segera tersedia')),
    );
  }

  void _showEditEmployeeDialog(Map<String, dynamic> employee) {
    // TODO: Implement edit employee dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur edit karyawan akan segera tersedia')),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus karyawan ${employee['name']}?',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await widget.onDeleteEmployee(employee['id'].toString());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Karyawan berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
