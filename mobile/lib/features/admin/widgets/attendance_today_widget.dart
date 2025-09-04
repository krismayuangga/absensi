import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class AttendanceTodayWidget extends StatefulWidget {
  final List<Map<String, dynamic>> attendanceList;
  final Map<String, dynamic>? attendanceStats;
  final Future<void> Function() onRefresh;

  const AttendanceTodayWidget({
    super.key,
    required this.attendanceList,
    required this.attendanceStats,
    required this.onRefresh,
  });

  @override
  State<AttendanceTodayWidget> createState() => _AttendanceTodayWidgetState();
}

class _AttendanceTodayWidgetState extends State<AttendanceTodayWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, present, late, absent

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredAttendance {
    List<Map<String, dynamic>> filtered = widget.attendanceList;

    // Filter by status
    if (_selectedFilter != 'all') {
      filtered = filtered.where((attendance) {
        final status = attendance['status']?.toString().toLowerCase() ?? '';
        return status == _selectedFilter;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((attendance) {
        final name =
            attendance['employee_name']?.toString().toLowerCase() ?? '';
        final nip = attendance['employee_nip']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return name.contains(query) || nip.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Column(
        children: [
          // Header with stats and filters
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                // Date header
                Row(
                  children: [
                    Icon(
                      Icons.today,
                      size: 20.w,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Absensi Hari Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID')
                          .format(DateTime.now()),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Stats row
                if (widget.attendanceStats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Hadir',
                          '${widget.attendanceStats!['present'] ?? 0}',
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          'Terlambat',
                          '${widget.attendanceStats!['late'] ?? 0}',
                          Colors.orange,
                          Icons.schedule,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          'Tidak Hadir',
                          '${widget.attendanceStats!['absent'] ?? 0}',
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          'Izin',
                          '${widget.attendanceStats!['permission'] ?? 0}',
                          Colors.blue,
                          Icons.event_note,
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

                SizedBox(height: 12.h),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Semua'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('present', 'Hadir'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('late', 'Terlambat'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('absent', 'Tidak Hadir'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('permission', 'Izin'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: filteredAttendance.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredAttendance.length,
                    itemBuilder: (context, index) {
                      final attendance = filteredAttendance[index];
                      return _buildAttendanceCard(attendance);
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
      padding: EdgeInsets.all(8.w),
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
            size: 16.w,
            color: color,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> attendance) {
    final status = attendance['status']?.toString().toLowerCase() ?? '';
    final clockInTime = attendance['clock_in_time'];
    final clockOutTime = attendance['clock_out_time'];

    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    String statusText = _getStatusText(status);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: attendance['employee_photo'] != null
                      ? NetworkImage(attendance['employee_photo'])
                      : null,
                  child: attendance['employee_photo'] == null
                      ? Text(
                          _getInitials(attendance['employee_name'] ?? ''),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
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
                      Text(
                        attendance['employee_name'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        attendance['employee_nip'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (attendance['employee_position'] != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          attendance['employee_position'],
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12.w,
                        color: statusColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Time information
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  // Clock In
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.login,
                              size: 14.w,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Masuk',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          clockInTime ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: Colors.grey.shade300,
                  ),

                  // Clock Out
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.logout,
                                size: 14.w,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Keluar',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            clockOutTime ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location info if available
            if (attendance['location'] != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14.w,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      attendance['location'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
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
            Icons.event_busy,
            size: 64.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Tidak ada data absensi'
                : 'Belum ada absensi hari ini',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Coba ubah filter atau kata kunci pencarian'
                : 'Data absensi akan muncul ketika karyawan mulai absen',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'permission':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      case 'permission':
        return Icons.event_note;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Tidak Hadir';
      case 'permission':
        return 'Izin';
      default:
        return 'Unknown';
    }
  }
}
