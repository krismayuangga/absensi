import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/attendance_provider.dart';
import '../attendance/clock_in_out_screen.dart';

class AttendanceMainScreen extends StatefulWidget {
  const AttendanceMainScreen({super.key});

  @override
  State<AttendanceMainScreen> createState() => _AttendanceMainScreenState();
}

class _AttendanceMainScreenState extends State<AttendanceMainScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's attendance when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final attendanceProvider = context.read<AttendanceProvider>();
      attendanceProvider.loadTodayAttendance();
      attendanceProvider.loadAttendanceHistory(limit: 5);
      attendanceProvider.loadAttendanceStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Absensi',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Clock Actions
            Row(
              children: [
                Expanded(
                  child: _buildClockCard(
                    title: 'Clock In',
                    subtitle: 'Masuk Kerja',
                    icon: Icons.login,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ClockInOutScreen(isClockOut: false),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildClockCard(
                    title: 'Clock Out',
                    subtitle: 'Pulang Kerja',
                    icon: Icons.logout,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ClockInOutScreen(isClockOut: true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Today's Status
            Text(
              'Status Hari Ini',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  if (attendanceProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      _buildStatusRow(
                          'Masuk Kerja',
                          attendanceProvider.getClockInTimeFormatted(),
                          Icons.login,
                          Colors.green),
                      Divider(height: 20.h),
                      _buildStatusRow(
                          'Pulang Kerja',
                          attendanceProvider.getClockOutTimeFormatted(),
                          Icons.logout,
                          Colors.orange),
                      Divider(height: 20.h),
                      _buildStatusRow(
                          'Total Jam',
                          attendanceProvider.getWorkingHoursFormatted(),
                          Icons.schedule,
                          Colors.blue),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 24.h),

            // Weekly Summary
            Text(
              'Ringkasan Minggu Ini',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  final stats = attendanceProvider.attendanceStats;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem('${stats?.presentDays ?? 0}',
                            'Hari Hadir', Colors.green),
                      ),
                      Container(
                          width: 1, height: 40.h, color: Colors.grey.shade300),
                      Expanded(
                        child: _buildSummaryItem(
                            '${stats?.averageWorkingHours.toStringAsFixed(0) ?? "0"}',
                            'Rata-rata Jam',
                            Colors.blue),
                      ),
                      Container(
                          width: 1, height: 40.h, color: Colors.grey.shade300),
                      Expanded(
                        child: _buildSummaryItem('${stats?.lateDays ?? 0}',
                            'Terlambat', Colors.orange),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 24.h),

            // Recent History
            Text(
              'Riwayat Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  if (attendanceProvider.attendanceHistory.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48.w,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Riwayat absensi akan muncul di sini',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...attendanceProvider.attendanceHistory
                          .take(3)
                          .map(
                            (attendance) => Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.w,
                                    height: 32.w,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(attendance.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.login,
                                      size: 16.w,
                                      color: _getStatusColor(attendance.status),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          attendance.statusIndonesian,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${attendance.date.day}/${attendance.date.month}/${attendance.date.year}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    attendance.clockInTimeFormatted ?? '--:--',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      if (attendanceProvider.attendanceHistory.length > 3)
                        TextButton(
                          onPressed: () {
                            // Navigate to full history
                          },
                          child: Text(
                            'Lihat semua aktivitas',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                size: 32.w,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.w,
            color: color,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'sick':
        return Colors.purple;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
