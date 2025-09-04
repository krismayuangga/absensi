import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/admin_stats_card.dart';
import 'widgets/attendance_today_widget.dart';
import 'widgets/employee_list_widget.dart';

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
    _tabController = TabController(length: 4, vsync: this);

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
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Employees'),
            Tab(icon: Icon(Icons.access_time), text: 'Attendance'),
            Tab(icon: Icon(Icons.event_note), text: 'Leaves'),
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
                        title: 'Total Employees',
                        value: stats['total_employees']?.toString() ?? '0',
                        icon: Icons.people,
                        color: Colors.blue,
                        subtitle: 'Active employees',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Today Attendance',
                        value: stats['today_attendance']?.toString() ?? '0',
                        icon: Icons.access_time,
                        color: Colors.green,
                        subtitle:
                            '${stats['attendance_percentage'] ?? 0}% present',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Pending Leaves',
                        value: stats['pending_leaves']?.toString() ?? '0',
                        icon: Icons.event_note,
                        color: Colors.orange,
                        subtitle: 'Need approval',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatsCard(
                        title: 'Monthly Average',
                        value: stats['monthly_average']?.toString() ?? '0',
                        icon: Icons.trending_up,
                        color: Colors.purple,
                        subtitle: 'Attendance per day',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Today's Attendance Widget
              const AttendanceTodayWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeesTab() {
    return const EmployeeListWidget();
  }

  Widget _buildAttendanceTab() {
    return const Center(
      child: Text(
        'Attendance Management',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildLeavesTab() {
    return const Center(
      child: Text(
        'Leave Management',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
