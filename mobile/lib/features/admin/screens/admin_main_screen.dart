import 'package:flutter/material.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/admin_content_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
                      // TODO: Add employee dialog
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
                // TODO: Edit employee dialog
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

class AdminKPITab extends StatelessWidget {
  const AdminKPITab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('KPI Analytics',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Coming Soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
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
}
