import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/attendance_provider.dart';
import '../../core/theme/app_theme.dart';
import '../attendance/clock_in_out_screen.dart';
import '../leave/screens/leave_screen.dart';
import '../../main_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    await attendanceProvider.loadTodayAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'Beranda',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.fetchProfile();
              await _loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Welcome Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 28.w,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang kembali,',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                user?.name ?? 'Admin User',
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'OZONE GROUP • ${_getRoleInIndonesian(user?.role)}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20.w,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Quick Actions Grid (Compact)
                  Text(
                    'Aksi Cepat',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // First Row - Primary Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.login,
                          title: 'Clock In',
                          color: Colors.green,
                          onTap: () => _handleClockIn(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.logout,
                          title: 'Clock Out',
                          color: Colors.orange,
                          onTap: () => _handleClockOut(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.event_available,
                          title: 'Cuti',
                          color: Colors.blue,
                          onTap: () => _handleLeaveRequest(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Second Row - Secondary Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.trending_up,
                          title: 'KPI',
                          color: Colors.purple,
                          onTap: () => _handleKPI(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.announcement,
                          title: 'Info',
                          color: Colors.cyan,
                          onTap: () => _handleInfo(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildCompactActionCard(
                          icon: Icons.history,
                          title: 'Riwayat',
                          color: Colors.indigo,
                          onTap: () => _handleHistory(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Today's Summary (Horizontal Cards)
                  Text(
                    'Ringkasan Hari Ini',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
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
                        return Row(
                          children: [
                            Expanded(
                              child: _buildSummaryMini(
                                'Masuk',
                                attendanceProvider.getClockInTimeFormatted(),
                                Icons.login,
                                Colors.green,
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 40.h,
                                color: Colors.grey.shade300),
                            Expanded(
                              child: _buildSummaryMini(
                                'Pulang',
                                attendanceProvider.getClockOutTimeFormatted(),
                                Icons.logout,
                                Colors.orange,
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 40.h,
                                color: Colors.grey.shade300),
                            Expanded(
                              child: _buildSummaryMini(
                                'Total',
                                attendanceProvider.getWorkingHoursFormatted(),
                                Icons.schedule,
                                Colors.blue,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Recent Activities (Compact List)
                  Text(
                    'Aktivitas Terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
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
                        // Get today's attendance data
                        final clockInTime =
                            attendanceProvider.getClockInTimeFormatted();
                        final clockOutTime =
                            attendanceProvider.getClockOutTimeFormatted();
                        final hasClockIn = clockInTime != '--:--';
                        final hasClockOut = clockOutTime != '--:--';

                        return Column(
                          children: [
                            if (hasClockIn)
                              _buildActivityItem(
                                'Clock In',
                                'Masuk kerja hari ini',
                                clockInTime,
                                Icons.login,
                                Colors.green,
                              ),
                            if (hasClockIn && hasClockOut)
                              Divider(
                                  height: 16.h, color: Colors.grey.shade200),
                            if (hasClockOut)
                              _buildActivityItem(
                                'Clock Out',
                                'Pulang kerja hari ini',
                                clockOutTime,
                                Icons.logout,
                                Colors.orange,
                              ),
                            if (!hasClockIn && !hasClockOut) ...[
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 32.w,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Belum ada aktivitas hari ini',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Divider(
                                  height: 16.h, color: Colors.grey.shade200),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Lihat semua aktivitas',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12.w,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
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

  Widget _buildCompactActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 18.w,
                color: color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMini(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 14.w,
            color: color,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 16.w,
            color: color,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getRoleInIndonesian(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'manager':
        return 'MANAJER';
      case 'employee':
        return 'KARYAWAN';
      case 'hr':
        return 'SDM';
      default:
        return role?.toUpperCase() ?? 'KARYAWAN';
    }
  }

  // Handler methods for quick actions
  void _handleClockIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClockInOutScreen(isClockOut: false),
      ),
    );
  }

  void _handleClockOut() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClockInOutScreen(isClockOut: true),
      ),
    );
  }

  void _handleLeaveRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LeaveScreen(),
      ),
    );
  }

  void _handleKPI() {
    // Navigate to KPI tab (index 2)
    NavigationController.changeTab(2);
  }

  void _handleInfo() {
    // Navigate to Info tab (index 3)
    NavigationController.changeTab(3);
  }

  void _handleHistory() {
    // Navigate to Attendance tab (index 1) which contains history
    NavigationController.changeTab(1);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Keluar',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();

                if (mounted) {
                  // Navigate back to login
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: Text(
                'Keluar',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
