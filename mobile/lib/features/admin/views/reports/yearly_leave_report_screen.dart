import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_theme.dart';

class YearlyLeaveReportScreen extends StatefulWidget {
  const YearlyLeaveReportScreen({Key? key}) : super(key: key);

  @override
  State<YearlyLeaveReportScreen> createState() =>
      _YearlyLeaveReportScreenState();
}

class _YearlyLeaveReportScreenState extends State<YearlyLeaveReportScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  String? _errorMessage;
  int _selectedYear = DateTime.now().year;
  String? _selectedType;
  String? _selectedStatus;

  final List<String> _leaveTypes = [
    'annual',
    'sick',
    'maternity',
    'emergency',
    'unpaid'
  ];

  final List<String> _leaveStatuses = ['pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      final result = await adminProvider.getDetailedLeaveReport(
        year: _selectedYear,
        type: _selectedType,
        status: _selectedStatus,
      );

      if (result['success'] == true) {
        setState(() {
          _reportData = result['data'];
        });

        // Debug: Log employees data
        final employees = result['data']['employees'] as List<dynamic>? ?? [];
        print('📊 DEBUG: Employees count: ${employees.length}');
        if (employees.isNotEmpty) {
          print('📊 DEBUG: First employee: ${employees.first}');
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load report';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFilterCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Laporan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Cuti',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Jenis'),
                      ),
                      ..._leaveTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getLeaveTypeName(type)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Status'),
                      ),
                      ..._leaveStatuses.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusName(status)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadReport,
                  icon: const Icon(Icons.search),
                  label: const Text('Cari'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_reportData == null) return const SizedBox.shrink();

    final summary = _reportData!['summary'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildSummaryCard(
            'Total Karyawan',
            summary['total_employees'].toString(),
            Icons.people,
            AppTheme.primaryColor,
          ),
          _buildSummaryCard(
            'Total Pengajuan Cuti',
            summary['total_leaves'].toString(),
            Icons.event_note,
            Colors.orange,
          ),
          _buildSummaryCard(
            'Rata-rata per Karyawan',
            '${summary['avg_leaves_per_employee']} hari',
            Icons.analytics,
            Colors.blue,
          ),
          _buildSummaryCard(
            'Total Hari Cuti',
            '${summary['total_days']} hari',
            Icons.calendar_today,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        height: 120, // Fixed height to prevent overflow
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color), // Smaller icon
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16, // Smaller font
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11, // Smaller label
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

  Widget _buildBreakdownSection() {
    if (_reportData == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildTypeBreakdown(),
        const SizedBox(height: 16),
        _buildStatusBreakdown(),
        const SizedBox(height: 16),
        _buildMonthlyTrend(),
        const SizedBox(height: 16),
        _buildEmployeeList(),
      ],
    );
  }

  Widget _buildTypeBreakdown() {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final breakdown = summary['leaves_by_type'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown per Jenis Cuti',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...breakdown.map((item) {
              final type = item['leave_type'] ?? 'unknown';
              final count = item['count'] ?? 0;
              final days = item['total_days'] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getLeaveTypeName(type)),
                    Text('$count pengajuan ($days hari)'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final breakdown = summary['leaves_by_status'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown per Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...breakdown.map((item) {
              final status = item['status'] ?? 'unknown';
              final count = item['count'] ?? 0;
              final days = item['total_days'] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getStatusName(status)),
                    Text('$count pengajuan ($days hari)'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final monthlyData = summary['monthly_trend'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren Bulanan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...monthlyData.map((item) {
              final month = item['nama_bulan'] ?? 'Unknown Month';
              final count = item['total_cuti'] ?? 0;
              final days = item['total_hari'] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(month),
                    Text('$count pengajuan ($days hari)'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    final employees = _reportData!['employees'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analisis per Karyawan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...employees.map((item) {
              final name = (item['name'] as String?) ?? 'Unknown';
              final email = (item['email'] as String?) ?? 'No email';
              final totalDays = (item['total_days'] as num?)?.toInt() ?? 0;
              final usagePercentage =
                  (item['usage_percentage'] as num?)?.toDouble() ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalDays hari',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${usagePercentage.toStringAsFixed(1)}% kuota',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getLeaveTypeName(String type) {
    switch (type) {
      case 'annual':
        return 'Cuti Tahunan';
      case 'sick':
        return 'Cuti Sakit';
      case 'maternity':
        return 'Cuti Melahirkan';
      case 'emergency':
        return 'Cuti Darurat';
      case 'unpaid':
        return 'Cuti Tanpa Gaji';
      default:
        return type;
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Cuti Tahunan'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildFilterCard(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadReport,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_reportData != null) ...[
                _buildSummaryCards(),
                const SizedBox(height: 16),
                _buildBreakdownSection(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
