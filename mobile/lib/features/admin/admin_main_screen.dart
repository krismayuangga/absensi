import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/admin_content_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/admin_stats_card.dart';
import 'widgets/attendance_today_widget.dart';
import 'widgets/employee_list_widget.dart';
import 'widgets/attendance_management_widget.dart';
import 'widgets/leave_management_widget.dart';
import 'widgets/recent_activities_widget.dart';
import 'widgets/admin_content_management_widget.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDashboardStats();
      adminProvider.loadMasterData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Karyawan'),
            Tab(icon: Icon(Icons.access_time), text: 'Kehadiran'),
            Tab(icon: Icon(Icons.event_note), text: 'Cuti'),
            Tab(icon: Icon(Icons.article), text: 'Konten'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildEmployeesTab(),
          _buildAttendanceTab(),
          _buildLeavesTab(),
          _buildContentTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  adminProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => adminProvider.loadDashboardStats(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = adminProvider.dashboardStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              if (stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Total Karyawan',
                        value: stats['total_karyawan']?.toString() ?? '0',
                        icon: Icons.people,
                        color: Colors.blue,
                        subtitle: 'Karyawan aktif',
                        onTap: () => _switchToTab(1), // Switch to Karyawan tab
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Hadir Hari Ini',
                        value: stats['hadir_hari_ini']?.toString() ?? '0',
                        icon: Icons.access_time,
                        color: Colors.green,
                        subtitle:
                            '${stats['persentase_kehadiran'] ?? 0}% hadir',
                        onTap: () => _switchToTab(2), // Switch to Kehadiran tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Cuti Pending',
                        value: stats['cuti_pending']?.toString() ?? '0',
                        icon: Icons.event_note,
                        color: Colors.orange,
                        subtitle: 'Perlu persetujuan',
                        onTap: () => _switchToTab(3), // Switch to Cuti tab
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Rata-rata Bulanan',
                        value: stats['rata_rata_bulanan']?.toString() ?? '0',
                        icon: Icons.trending_up,
                        color: Colors.purple,
                        subtitle: 'Kehadiran per hari',
                        onTap: () => _switchToTab(2), // Switch to Kehadiran tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Today's Attendance Widget
              const AttendanceTodayWidget(),

              // Recent Activities Widget
              const RecentActivitiesWidget(),
            ],
          ),
        );
      },
    );
  }

  void _switchToTab(int index) {
    _tabController.animateTo(index);
  }

  Widget _buildEmployeesTab() {
    return const EmployeeListWidget();
  }

  Widget _buildAttendanceTab() {
    return const AttendanceManagementWidget();
  }

  Widget _buildLeavesTab() {
    return const LeaveManagementWidget();
  }

  Widget _buildContentTab() {
    return const AdminContentManagementWidget();
  }
}
