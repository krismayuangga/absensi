import 'package:flutter/material.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/admin_content_provider.dart';
import '../widgets/employee_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardTab(),
    const AdminManagementTab(),
    const AdminAnalyticsTab(),
    const AdminSettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminProvider>().loadDashboardStats();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        iconSize: 20,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Manajemen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analitik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (adminProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  adminProvider.errorMessage ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    adminProvider.loadDashboardStats();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = adminProvider.dashboardStats;

        return RefreshIndicator(
          onRefresh: () async {
            await adminProvider.loadDashboardStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                if (stats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Employees',
                          '${stats?['total_karyawan'] ?? 0}',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Today Attendance',
                          '${stats?['hadir_hari_ini'] ?? 0}',
                          Icons.access_time,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Attendance %',
                          '${stats?['persentase_kehadiran'] ?? 0}%',
                          Icons.percent,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Pending Leaves',
                          '${stats?['cuti_pending'] ?? 0}',
                          Icons.pending_actions,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Recent Activities
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                if (adminProvider.recentActivities.isNotEmpty)
                  ...adminProvider.recentActivities.map(
                    (activity) => _buildActivityItem(context, activity),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent activities',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            _getActivityIcon(activity['aksi'] ?? ''),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          activity['nama_karyawan'] ?? 'Unknown Employee',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${activity['aksi'] ?? 'Unknown action'} - ${activity['kode_karyawan'] ?? 'N/A'}'),
            Text(
              '${activity['tanggal'] ?? ''} ${activity['waktu'] ?? ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(activity['status'] ?? ''),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            activity['status'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'masuk':
        return Icons.login;
      case 'keluar':
        return Icons.logout;
      case 'clock_in':
        return Icons.login;
      case 'clock_out':
        return Icons.logout;
      case 'break_start':
        return Icons.coffee;
      case 'break_end':
        return Icons.work;
      default:
        return Icons.access_time;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'tepat waktu':
      case 'normal':
        return Colors.green;
      case 'late':
      case 'terlambat':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'pulang cepat':
        return Colors.orange.shade300;
      case 'lembur':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class AdminEmployeesTab extends StatefulWidget {
  const AdminEmployeesTab({Key? key}) : super(key: key);

  @override
  State<AdminEmployeesTab> createState() => _AdminEmployeesTabState();
}

class _AdminEmployeesTabState extends State<AdminEmployeesTab> {
  @override
  void initState() {
    super.initState();
    // Load employees when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadEmployees(refresh: true);
      context.read<AdminProvider>().loadMasterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Data Karyawan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddEmployeeDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Employee List
            Expanded(
              child: adminProvider.isLoadingEmployees &&
                      adminProvider.employees.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.employees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data karyawan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Klik tombol Tambah untuk menambah karyawan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await adminProvider.loadEmployees(refresh: true);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: adminProvider.employees.length +
                                (adminProvider.hasMoreEmployees ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == adminProvider.employees.length) {
                                // Load more indicator
                                if (adminProvider.isLoadingEmployees) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                } else if (adminProvider.hasMoreEmployees) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        adminProvider.loadEmployees();
                                      },
                                      child: const Text('Load More'),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              final employee = adminProvider.employees[index];
                              return _buildEmployeeCard(
                                  context, employee, adminProvider);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Map<String, dynamic> employee,
      AdminProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            _getEmployeeInitial(employee['name']),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'ID: ${employee['employee_id'] ?? employee['employee_code'] ?? 'N/A'}'),
            Text('Email: ${employee['email'] ?? 'N/A'}'),
            Text('Jabatan: ${_getEmployeePosition(employee)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditEmployeeDialog(context, employee);
                break;
              case 'delete':
                _showDeleteConfirmation(context, employee, provider);
                break;
            }
          },
          itemBuilder: (context) => [
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
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context,
      Map<String, dynamic> employee, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Apakah Anda yakin ingin menghapus karyawan ${employee['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteEmployee(employee['id']);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Karyawan berhasil dihapus')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          provider.errorMessage ?? 'Gagal menghapus karyawan')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getEmployeeInitial(dynamic name) {
    final nameStr = name?.toString() ?? 'U';
    if (nameStr.isEmpty) return 'U';
    return nameStr.substring(0, 1).toUpperCase();
  }

  String _getEmployeePosition(Map<String, dynamic> employee) {
    final position = employee['position'];
    if (position == null) return 'N/A';

    if (position is Map<String, dynamic>) {
      return position['name']?.toString() ?? 'N/A';
    } else if (position is String) {
      return position;
    }

    return position.toString();
  }

  /// Show add employee dialog
  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmployeeFormDialog(
        adminProvider: context.read<AdminProvider>(),
      ),
    );
  }

  /// Show edit employee dialog
  void _showEditEmployeeDialog(
      BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmployeeFormDialog(
        employee: employee,
        adminProvider: context.read<AdminProvider>(),
      ),
    );
  }
}

// Management Tab with sub-tabs
class AdminManagementTab extends StatefulWidget {
  const AdminManagementTab({Key? key}) : super(key: key);

  @override
  State<AdminManagementTab> createState() => _AdminManagementTabState();
}

class _AdminManagementTabState extends State<AdminManagementTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            isScrollable: false,
            tabs: const [
              Tab(text: 'Karyawan', icon: Icon(Icons.people, size: 18)),
              Tab(text: 'Kehadiran', icon: Icon(Icons.access_time, size: 18)),
              Tab(text: 'Cuti', icon: Icon(Icons.event_busy, size: 18)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminEmployeesTab(),
              AdminAttendanceTab(),
              AdminLeaveTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Analytics Tab with sub-tabs
class AdminAnalyticsTab extends StatefulWidget {
  const AdminAnalyticsTab({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsTab> createState() => _AdminAnalyticsTabState();
}

class _AdminAnalyticsTabState extends State<AdminAnalyticsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            isScrollable: false,
            tabs: const [
              Tab(text: 'KPI', icon: Icon(Icons.trending_up, size: 18)),
              Tab(text: 'Laporan', icon: Icon(Icons.assessment, size: 18)),
              Tab(text: 'Charts', icon: Icon(Icons.bar_chart, size: 18)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminKPITab(),
              AdminReportsTab(),
              AdminChartsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Settings Tab with sub-tabs
class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({Key? key}) : super(key: key);

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            isScrollable: false,
            tabs: const [
              Tab(text: 'Konten', icon: Icon(Icons.article, size: 18)),
              Tab(text: 'Profil', icon: Icon(Icons.person, size: 18)),
              Tab(text: 'Sistem', icon: Icon(Icons.tune, size: 18)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminContentTab(),
              AdminProfileTab(),
              AdminSystemTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Leave Management Tab with real data
class AdminLeaveTab extends StatefulWidget {
  const AdminLeaveTab({Key? key}) : super(key: key);

  @override
  State<AdminLeaveTab> createState() => _AdminLeaveTabState();
}

class _AdminLeaveTabState extends State<AdminLeaveTab> {
  String? _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadLeaveRequests(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Row(
                children: [
                  const Text('Status:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('Semua Status')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'approved', child: Text('Disetujui')),
                        DropdownMenuItem(
                            value: 'rejected', child: Text('Ditolak')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                        context.read<AdminProvider>().loadLeaveRequests(
                              refresh: true,
                              status: value,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<AdminProvider>()
                          .loadLeaveRequests(refresh: true);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            // Leave Requests List
            Expanded(
              child: adminProvider.isLoadingLeaves
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.leaveRequests.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Belum ada pengajuan cuti',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: adminProvider.leaveRequests.length,
                          itemBuilder: (context, index) {
                            final leave = adminProvider.leaveRequests[index];
                            return _buildLeaveCard(
                                context, leave, adminProvider);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> leave,
      AdminProvider adminProvider) {
    final status = leave['status'] ?? 'pending';
    final statusColor = _getLeaveStatusColor(status);
    final statusText = _getLeaveStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getLeaveStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          leave['user']?['name'] ?? 'Unknown Employee',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${leave['user']?['employee_id'] ?? 'N/A'}'),
            Text('Jenis: ${leave['type'] ?? 'N/A'}'),
            Text(
                '${_formatDate(leave['start_date'])} - ${_formatDate(leave['end_date'])}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alasan:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(leave['reason'] ?? 'Tidak ada keterangan'),
                const SizedBox(height: 12),
                if (leave['notes'] != null &&
                    leave['notes'].toString().isNotEmpty) ...[
                  const Text('Catatan Admin:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(leave['notes']),
                  const SizedBox(height: 12),
                ],
                if (status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveLeave(
                              context, leave['id'], adminProvider),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _rejectLeave(context, leave['id'], adminProvider),
                          icon: const Icon(Icons.close, size: 18),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLeaveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getLeaveStatusText(String status) {
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

  IconData _getLeaveStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  void _approveLeave(
      BuildContext context, int leaveId, AdminProvider adminProvider) {
    _showLeaveActionDialog(
      context,
      'Setujui Cuti',
      'Apakah Anda yakin ingin menyetujui pengajuan cuti ini?',
      () async {
        final success = await adminProvider.approveLeave(leaveId, '');
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajuan cuti berhasil disetujui')),
          );
        }
      },
    );
  }

  void _rejectLeave(
      BuildContext context, int leaveId, AdminProvider adminProvider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Cuti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await adminProvider.rejectLeave(
                leaveId,
                reasonController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pengajuan cuti berhasil ditolak')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveActionDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  // Helper method untuk format tanggal
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class AdminKPITab extends StatefulWidget {
  const AdminKPITab({Key? key}) : super(key: key);

  @override
  _AdminKPITabState createState() => _AdminKPITabState();
}

class _AdminKPITabState extends State<AdminKPITab> {
  @override
  void initState() {
    super.initState();
    // Load data after frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKpiData();
    });
  }

  Future<void> _loadKpiData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.loadKpiAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (adminProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  adminProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadKpiData,
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final analytics = adminProvider.kpiAnalytics;
        if (analytics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 48),
                SizedBox(height: 16),
                Text('Tidak ada data KPI'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadKpiData,
                  child: Text('Muat Data'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadKpiData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards - Kompak
                _buildStatisticsSection(analytics['statistics']),
                SizedBox(height: 16),

                // Active Prospects - Kompak dengan detail click
                _buildActiveProspectsSection(analytics['active_prospects']),
                SizedBox(height: 16),

                // Pending Visits - Kompak dengan detail click
                _buildPendingVisitsSection(analytics['pending_visits']),
                SizedBox(height: 16),

                // Top Employees - Kompak
                _buildTopEmployeesSection(analytics['top_employees']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic>? stats) {
    if (stats == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Kunjungan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        // Layout 4 kolom sejajar dalam 1 baris
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hari Ini',
                '${stats['visits_today'] ?? 0}',
                Icons.today,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Minggu Ini',
                '${stats['visits_this_week'] ?? 0}',
                Icons.date_range,
                Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Bulan Ini',
                '${stats['visits_this_month'] ?? 0}',
                Icons.calendar_month,
                Colors.orange,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Tingkat Sukses',
                '${stats['success_rate'] ?? 0}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildPotentialValueCard(stats['total_potential_value']),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialValueCard(dynamic potentialValue) {
    final value = potentialValue ?? 0;
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Colors.teal.withOpacity(0.1),
              Colors.teal.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet, size: 32, color: Colors.teal),
            SizedBox(height: 8),
            Text(
              'Total Nilai Potensial',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Rp ${_formatCurrency(value)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProspectsSection(List<dynamic>? prospects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prospek Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${prospects?.length ?? 0} prospek',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        prospects == null || prospects.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.business_center,
                          size: 40, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada prospek aktif',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: prospects
                    .take(3)
                    .map((prospect) => _buildProspectCard(prospect))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildProspectCard(Map<String, dynamic> prospect) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showProspectDetail(prospect),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 20,
                child: Icon(Icons.business, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prospect['client_name'] ?? 'Nama Tidak Tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${prospect['address'] ?? 'Alamat tidak tersedia'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'PIC: ${prospect['employee_name'] ?? 'Belum ditentukan'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    prospect['formatted_potential_value'] ?? 'Rp 0',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${prospect['visits_count'] ?? 0} kunjungan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingVisitsSection(List<dynamic>? visits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kunjungan Pending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${visits?.length ?? 0} pending',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        visits == null || visits.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle,
                          size: 40, color: Colors.green[400]),
                      SizedBox(height: 12),
                      Text(
                        'Semua kunjungan sudah selesai',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: visits
                    .take(3)
                    .map((visit) => _buildPendingVisitCard(visit))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildPendingVisitCard(Map<String, dynamic> visit) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showVisitDetail(visit),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[100],
                radius: 20,
                child: Icon(Icons.schedule, color: Colors.orange, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit['client_name'] ?? 'Prospek Tidak Tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Oleh: ${visit['employee_name'] ?? 'Karyawan tidak tersedia'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tgl: ${_formatDate(visit['visit_date'])}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopEmployeesSection(List<dynamic>? employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        employees == null || employees.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.people, size: 40, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada data karyawan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: employees.asMap().entries.take(3).map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> employee = entry.value;
                  return _buildTopEmployeeCard(employee, index + 1);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTopEmployeeCard(Map<String, dynamic> employee, int rank) {
    Color rankColor;
    IconData rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankIcon = Icons.military_tech;
        break;
      case 3:
        rankColor = Colors.brown[400]!;
        rankIcon = Icons.workspace_premium;
        break;
      default:
        rankColor = Colors.blue;
        rankIcon = Icons.star;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showEmployeeDetail(employee),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: rankColor.withOpacity(0.1),
                radius: 20,
                child: Icon(rankIcon, color: rankColor, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee['employee_name'] ?? 'Nama Tidak Tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${employee['visit_count'] ?? 0} kunjungan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Success Rate: ${employee['success_rate'] ?? 0}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    employee['formatted_potential'] ?? 'Rp 0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // Detail Dialog Functions
  void _showProspectDetail(Map<String, dynamic> prospect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.business, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                prospect['client_name'] ?? 'Detail Prospek',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  'Nama Prospek', prospect['client_name'] ?? 'Tidak tersedia'),
              _buildDetailRow(
                  'Alamat', prospect['address'] ?? 'Tidak tersedia'),
              _buildDetailRow('PIC Karyawan',
                  prospect['employee_name'] ?? 'Belum ditentukan'),
              _buildDetailRow('ID Karyawan', prospect['employee_id'] ?? 'N/A'),
              _buildDetailRow('Tujuan Kunjungan',
                  prospect['visit_purpose'] ?? 'Tidak tersedia'),
              _buildDetailRow('Nilai Potensial',
                  prospect['formatted_potential_value'] ?? 'Rp 0'),
              _buildDetailRow('Status', prospect['status'] ?? 'pending'),
              _buildDetailRow(
                  'Waktu Kunjungan', _formatDate(prospect['start_time'])),
              if (prospect['notes'] != null &&
                  prospect['notes'].toString().isNotEmpty)
                _buildDetailRow('Catatan', prospect['notes']),

              SizedBox(height: 16),

              // Foto Section
              if (prospect['photo_url'] != null &&
                  prospect['photo_url'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Foto Kunjungan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: prospect['photo_url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey[400]),
                                    SizedBox(height: 8),
                                    Text('Foto tidak dapat dimuat',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),

              // Location Section
              if (prospect['latitude'] != null && prospect['longitude'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Lokasi Kunjungan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koordinat GPS:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lat: ${prospect['latitude']}\nLng: ${prospect['longitude']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              _openGoogleMaps(
                                  prospect['latitude'], prospect['longitude']);
                            },
                            icon: Icon(Icons.map, size: 16),
                            label: Text('Buka di Maps'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),

              // Info message when no photo/location available
              if ((prospect['photo_url'] == null ||
                      prospect['photo_url'].toString().isEmpty) &&
                  (prospect['latitude'] == null ||
                      prospect['longitude'] == null))
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Informasi Tambahan',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Foto dan lokasi kunjungan belum tersedia untuk data ini.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showVisitDetail(Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Detail Kunjungan Pending',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  'Prospek', visit['prospect_name'] ?? 'Tidak tersedia'),
              _buildDetailRow(
                  'Karyawan', visit['employee_name'] ?? 'Tidak tersedia'),
              _buildDetailRow(
                  'Tanggal Kunjungan', _formatDate(visit['visit_date'])),
              _buildDetailRow('Status', 'PENDING'),
              _buildDetailRow('Waktu Dibuat', _formatDate(visit['created_at'])),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Foto & Lokasi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Foto lokasi, GPS coordinates, dan detail kunjungan akan tampil setelah kunjungan selesai.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetail(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.purple),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                employee['name'] ?? 'Detail Karyawan',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  'Nama Karyawan', employee['name'] ?? 'Tidak tersedia'),
              _buildDetailRow('Total Kunjungan',
                  '${employee['visits_count'] ?? 0} kunjungan'),
              _buildDetailRow(
                  'Success Rate', '${employee['success_rate'] ?? 0}%'),
              _buildDetailRow('Total Nilai Potensial',
                  'Rp ${_formatCurrency(employee['total_potential'] ?? 0)}'),
              _buildDetailRow('Status', 'Aktif'),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, size: 16, color: Colors.purple),
                        SizedBox(width: 4),
                        Text(
                          'Analisis Performa',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Grafik performa, riwayat kunjungan detail, dan analisis mendalam akan ditampilkan di halaman khusus.',
                      style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final number = double.tryParse(value.toString()) ?? 0;
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}M';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}Jt';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  // Open Google Maps with coordinates
  void _openGoogleMaps(dynamic latitude, dynamic longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koordinat lokasi tidak tersedia')),
      );
      return;
    }

    final lat = latitude.toString();
    final lng = longitude.toString();
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka Google Maps: $e')),
      );
    }
  }
}

class AdminChartsTab extends StatelessWidget {
  const AdminChartsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Charts & Graphs',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Coming Soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile Settings',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Coming Soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class AdminSystemTab extends StatelessWidget {
  const AdminSystemTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tune, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('System Settings',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Coming Soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class AdminAttendanceTab extends StatefulWidget {
  const AdminAttendanceTab({Key? key}) : super(key: key);

  @override
  State<AdminAttendanceTab> createState() => _AdminAttendanceTabState();
}

class _AdminAttendanceTabState extends State<AdminAttendanceTab> {
  String? _selectedDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Load attendance records when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAttendanceRecords(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Kehadiran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(_selectedDate ?? 'Pilih Tanggal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          hint: const Text('Status'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: null, child: Text('Semua Status')),
                            DropdownMenuItem(
                                value: 'present', child: Text('Hadir')),
                            DropdownMenuItem(
                                value: 'late', child: Text('Terlambat')),
                            DropdownMenuItem(
                                value: 'absent', child: Text('Tidak Hadir')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                            _applyFilters();
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
              child: adminProvider.isLoadingAttendance &&
                      adminProvider.attendanceRecords.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : adminProvider.attendanceRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data kehadiran',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if (adminProvider.errorMessage != null)
                                Text(
                                  adminProvider.errorMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.red[600],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await adminProvider.loadAttendanceRecords(
                                refresh: true);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: adminProvider.attendanceRecords.length +
                                (adminProvider.hasMoreAttendance ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index ==
                                  adminProvider.attendanceRecords.length) {
                                // Load more indicator
                                if (adminProvider.isLoadingAttendance) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                } else if (adminProvider.hasMoreAttendance) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        adminProvider.loadAttendanceRecords();
                                      },
                                      child: const Text('Load More'),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              final attendance =
                                  adminProvider.attendanceRecords[index];
                              return _buildAttendanceCard(context, attendance);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceCard(
      BuildContext context, Map<String, dynamic> attendance) {
    final status = attendance['status'] ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          attendance['user']?['name'] ?? 'Unknown Employee',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${attendance['user']?['employee_id'] ?? 'N/A'}'),
            Text('Tanggal: ${_formatDate(attendance['date'])}'),
            if (attendance['clock_in_time'] != null)
              Text('Masuk: ${_formatTime(attendance['clock_in_time'])}'),
            if (attendance['clock_out_time'] != null)
              Text('Keluar: ${_formatTime(attendance['clock_out_time'])}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'tepat waktu':
      case 'normal':
        return Colors.green;
      case 'late':
      case 'terlambat':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'pulang cepat':
        return Colors.orange.shade300;
      case 'lembur':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Tidak Hadir';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    context.read<AdminProvider>().loadAttendanceRecords(
          refresh: true,
          date: _selectedDate,
          status: _selectedStatus,
        );
  }

  // Helper methods untuk format tanggal dan waktu
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    try {
      final time = DateTime.parse('2000-01-01 $timeStr');
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      try {
        final time = DateTime.parse(timeStr);
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } catch (e2) {
        return timeStr;
      }
    }
  }
}

class AdminContentTab extends StatefulWidget {
  const AdminContentTab({Key? key}) : super(key: key);

  @override
  State<AdminContentTab> createState() => _AdminContentTabState();
}

class _AdminContentTabState extends State<AdminContentTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            isScrollable: false,
            tabs: const [
              Tab(text: 'Pengumuman', icon: Icon(Icons.campaign, size: 20)),
              Tab(text: 'Media', icon: Icon(Icons.photo_library, size: 20)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminAnnouncementsTab(),
              AdminMediaTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminAnnouncementsTab extends StatefulWidget {
  const AdminAnnouncementsTab({Key? key}) : super(key: key);

  @override
  State<AdminAnnouncementsTab> createState() => _AdminAnnouncementsTabState();
}

class _AdminAnnouncementsTabState extends State<AdminAnnouncementsTab> {
  @override
  void initState() {
    super.initState();
    // Load announcements when tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminContentProvider>().loadAnnouncements(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminContentProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kelola Pengumuman',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateAnnouncementDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Pengumuman'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Error message
                if (provider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.clearError,
                          icon: const Icon(Icons.close),
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: provider.isLoadingAnnouncements
                      ? const Center(child: CircularProgressIndicator())
                      : provider.announcements.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada pengumuman',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap tombol "Buat Pengumuman" untuk membuat pengumuman pertama',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[500],
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () =>
                                  provider.loadAnnouncements(refresh: true),
                              child: ListView.builder(
                                itemCount: provider.announcements.length,
                                itemBuilder: (context, index) {
                                  final announcement =
                                      provider.announcements[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            provider.getPriorityColor(
                                                announcement['priority']),
                                        child: const Icon(
                                          Icons.campaign,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        announcement['title'] ?? 'Untitled',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            announcement['excerpt'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color:
                                                      provider.getPriorityColor(
                                                          announcement[
                                                              'priority']),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  provider.getPriorityLabel(
                                                      announcement['priority']),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                announcement['created_at'] ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Hapus'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showCreateAnnouncementDialog(
                                              context,
                                              isEdit: true,
                                              announcement: announcement,
                                            );
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(
                                                context, announcement['id']);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateAnnouncementDialog(
    BuildContext context, {
    bool isEdit = false,
    Map<String, dynamic>? announcement,
  }) {
    showDialog(
      context: context,
      builder: (context) => CreateAnnouncementDialog(
        isEdit: isEdit,
        announcement: announcement,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content:
            const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<AdminContentProvider>()
                  .deleteAnnouncement(id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengumuman berhasil dihapus')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menghapus pengumuman'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class AdminMediaTab extends StatelessWidget {
  const AdminMediaTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kelola Media & Galeri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUploadMediaDialog(context),
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Media'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6, // Mock data
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            child: Icon(
                              index % 2 == 0 ? Icons.image : Icons.description,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Media ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  index % 2 == 0 ? 'Gambar' : 'Dokumen',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${index + 1} hari lalu',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      itemBuilder: (context) => [
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
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 16),
                                              SizedBox(width: 8),
                                              Text('Hapus'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _showDeleteMediaConfirmation(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UploadMediaDialog(),
    );
  }

  void _showDeleteMediaConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Media'),
        content: const Text('Apakah Anda yakin ingin menghapus media ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class CreateAnnouncementDialog extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? announcement;

  const CreateAnnouncementDialog({
    Key? key,
    this.isEdit = false,
    this.announcement,
  }) : super(key: key);

  @override
  State<CreateAnnouncementDialog> createState() =>
      _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<CreateAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _priority = 'medium';
  String _category = 'general';
  bool _sendNotification = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.announcement != null) {
      _titleController.text = widget.announcement!['title'] ?? '';
      _contentController.text = widget.announcement!['content'] ?? '';
      _priority = widget.announcement!['priority'] ?? 'medium';
      _category = widget.announcement!['category'] ?? 'general';
      _sendNotification = widget.announcement!['send_notification'] ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminContentProvider>(
      builder: (context, provider, child) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEdit ? 'Edit Pengumuman' : 'Buat Pengumuman Baru',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Judul Pengumuman',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Judul harus diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Isi Pengumuman',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Isi pengumuman harus diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _priority,
                            decoration: const InputDecoration(
                              labelText: 'Prioritas',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'urgent', child: Text('Mendesak')),
                              DropdownMenuItem(
                                  value: 'high', child: Text('Tinggi')),
                              DropdownMenuItem(
                                  value: 'medium', child: Text('Sedang')),
                              DropdownMenuItem(
                                  value: 'low', child: Text('Rendah')),
                            ],
                            onChanged: (value) =>
                                setState(() => _priority = value!),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'general', child: Text('Umum')),
                              DropdownMenuItem(
                                  value: 'system', child: Text('Sistem')),
                              DropdownMenuItem(
                                  value: 'event', child: Text('Event')),
                              DropdownMenuItem(
                                  value: 'policy', child: Text('Kebijakan')),
                            ],
                            onChanged: (value) =>
                                setState(() => _category = value!),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text('Kirim Notifikasi Push'),
                            value: _sendNotification,
                            onChanged: (value) =>
                                setState(() => _sendNotification = value!),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: provider.isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(widget.isEdit ? 'Update' : 'Publish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AdminContentProvider>();

      bool success;
      if (widget.isEdit && widget.announcement != null) {
        success = await provider.updateAnnouncement(
          id: widget.announcement!['id'],
          title: _titleController.text,
          content: _contentController.text,
          priority: _priority,
          category: _category,
          sendNotification: _sendNotification,
        );
      } else {
        success = await provider.createAnnouncement(
          title: _titleController.text,
          content: _contentController.text,
          priority: _priority,
          category: _category,
          sendNotification: _sendNotification,
        );
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Pengumuman berhasil diupdate'
                  : 'Pengumuman berhasil dipublish',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class UploadMediaDialog extends StatefulWidget {
  const UploadMediaDialog({Key? key}) : super(key: key);

  @override
  State<UploadMediaDialog> createState() => _UploadMediaDialogState();
}

class _UploadMediaDialogState extends State<UploadMediaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _mediaType = 'image';
  String _category = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Media Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement file picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Pilih file akan diimplementasi')),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih file',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'JPG, PNG, PDF, DOC maksimal 5MB',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Media',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (opsional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _mediaType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Media',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'image', child: Text('Gambar')),
                          DropdownMenuItem(
                              value: 'document', child: Text('Dokumen')),
                          DropdownMenuItem(
                              value: 'video', child: Text('Video')),
                        ],
                        onChanged: (value) =>
                            setState(() => _mediaType = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'general', child: Text('Umum')),
                          DropdownMenuItem(
                              value: 'training', child: Text('Training')),
                          DropdownMenuItem(
                              value: 'event', child: Text('Event')),
                          DropdownMenuItem(
                              value: 'policy', child: Text('Kebijakan')),
                        ],
                        onChanged: (value) =>
                            setState(() => _category = value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement API call to upload media
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media berhasil diupload')),
      );
    }
  }
}

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan & Analitik',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Quick Stats from Dashboard
              if (adminProvider.dashboardStats != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Hari Ini',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStat(
                                context,
                                'Total Karyawan',
                                '${adminProvider.dashboardStats?['stats']?['total_employees'] ?? 0}',
                                Icons.people,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickStat(
                                context,
                                'Kehadiran Hari Ini',
                                '${adminProvider.dashboardStats?['stats']?['today_attendance'] ?? 0}',
                                Icons.access_time,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Report Menu Grid
              Text(
                'Jenis Laporan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildReportCard(
                      context,
                      'Laporan Kehadiran Harian',
                      'Detail kehadiran karyawan per hari',
                      Icons.calendar_view_day,
                      Colors.green,
                      onTap: () =>
                          _showComingSoon(context, 'Laporan Kehadiran Harian'),
                    ),
                    _buildReportCard(
                      context,
                      'Laporan Kehadiran Bulanan',
                      'Ringkasan kehadiran per bulan',
                      Icons.calendar_month,
                      Colors.blue,
                      onTap: () =>
                          _showComingSoon(context, 'Laporan Kehadiran Bulanan'),
                    ),
                    _buildReportCard(
                      context,
                      'Laporan Cuti',
                      'Status dan history cuti karyawan',
                      Icons.event_busy,
                      Colors.orange,
                      onTap: () => _showComingSoon(context, 'Laporan Cuti'),
                    ),
                    _buildReportCard(
                      context,
                      'Laporan KPI',
                      'Performance indicator karyawan',
                      Icons.trending_up,
                      Colors.purple,
                      onTap: () => _showComingSoon(context, 'Laporan KPI'),
                    ),
                    _buildReportCard(
                      context,
                      'Analitik Produktivitas',
                      'Analisa produktivitas tim',
                      Icons.analytics,
                      Colors.teal,
                      onTap: () =>
                          _showComingSoon(context, 'Analitik Produktivitas'),
                    ),
                    _buildReportCard(
                      context,
                      'Export Data',
                      'Export data ke Excel/PDF',
                      Icons.file_download,
                      Colors.red,
                      onTap: () => _showComingSoon(context, 'Export Data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('Fitur $feature akan tersedia pada update berikutnya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper functions for date and time formatting
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'N/A';
    try {
      // Handle both full datetime and time only
      if (timeStr.contains('T')) {
        final dateTime = DateTime.parse(timeStr);
        return DateFormat('HH:mm').format(dateTime);
      } else {
        // Assume it's already time format HH:mm:ss
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          return '${parts[0]}:${parts[1]}';
        }
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showProspectDetail(
      BuildContext context, Map<String, dynamic> prospect) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prospect['client_name'] ?? 'Detail Prospek',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildRowInline(
                          'Nama Klien', prospect['client_name'] ?? 'N/A'),
                      _buildRowInline(
                          'PIC', prospect['employee_name'] ?? 'N/A'),
                      _buildRowInline('Alamat', prospect['address'] ?? 'N/A'),
                      _buildRowInline('Tujuan Kunjungan',
                          prospect['visit_purpose'] ?? 'N/A'),
                      _buildRowInline('Status', prospect['status'] ?? 'N/A'),
                      _buildRowInline('Nilai Potensial',
                          'Rp ${_formatCurrency(prospect['potential_value'] ?? 0)}'),
                      _buildRowInline('Waktu Kunjungan',
                          _formatDateInline(prospect['start_time'])),

                      if (prospect['notes'] != null &&
                          prospect['notes'].toString().isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Catatan:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(prospect['notes'].toString()),
                        ),
                      ],

                      // Photo Section
                      if (prospect['photo_url'] != null &&
                          prospect['photo_url'].toString().isNotEmpty) ...[
                        SizedBox(height: 20),
                        Text(
                          'Foto Kunjungan:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: prospect['photo_url'].toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image,
                                          size: 48, color: Colors.grey[400]),
                                      SizedBox(height: 8),
                                      Text('Foto tidak dapat dimuat',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      // Location Section
                      if (prospect['latitude'] != null &&
                          prospect['longitude'] != null) ...[
                        SizedBox(height: 20),
                        Text(
                          'Lokasi Kunjungan:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Koordinat GPS:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Lat: ${prospect['latitude']}, Lng: ${prospect['longitude']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Open in maps
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Membuka di peta...')),
                                  );
                                },
                                icon:
                                    Icon(Icons.open_in_new, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showVisitDetail(BuildContext context, Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detail Kunjungan Pending',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRowInline(
                          'Nama Prospek',
                          visit['prospect_name'] ??
                              visit['client_name'] ??
                              'N/A'),
                      _buildRowInline('PIC', visit['employee_name'] ?? 'N/A'),
                      _buildRowInline(
                          'Tanggal Kunjungan', visit['start_time'] ?? 'N/A'),
                      _buildRowInline('Status', visit['status'] ?? 'N/A'),
                      _buildRowInline('Alamat', visit['address'] ?? 'N/A'),

                      // Photo Section
                      if (visit['photo_url'] != null &&
                          visit['photo_url'].toString().isNotEmpty) ...[
                        SizedBox(height: 20),
                        Text(
                          'Foto Kunjungan:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: visit['photo_url'].toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image,
                                          size: 48, color: Colors.grey[400]),
                                      SizedBox(height: 8),
                                      Text('Foto tidak dapat dimuat',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      // Location Section
                      if (visit['latitude'] != null &&
                          visit['longitude'] != null) ...[
                        SizedBox(height: 20),
                        Text(
                          'Lokasi Kunjungan:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Koordinat GPS:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Lat: ${visit['latitude']}, Lng: ${visit['longitude']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Membuka di peta...')),
                                  );
                                },
                                icon: Icon(Icons.open_in_new,
                                    color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Helper methods untuk AdminReportsTab
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final number = double.tryParse(value.toString()) ?? 0;
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}M';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}Jt';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatDateInline(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildRowInline(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
