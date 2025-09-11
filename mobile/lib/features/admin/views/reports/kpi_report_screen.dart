import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/admin_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class KpiReportScreen extends StatefulWidget {
  const KpiReportScreen({Key? key}) : super(key: key);

  @override
  State<KpiReportScreen> createState() => _KpiReportScreenState();
}

class _KpiReportScreenState extends State<KpiReportScreen> {
  String _selectedPeriod = 'month';
  String _selectedEmployeeId = '';
  bool _isLoading = false;

  final List<Map<String, String>> _periods = [
    {'value': 'today', 'label': 'Hari Ini'},
    {'value': 'week', 'label': 'Minggu Ini'},
    {'value': 'month', 'label': 'Bulan Ini'},
    {'value': 'year', 'label': 'Tahun Ini'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKpiData();
    });
  }

  Future<void> _loadKpiData() async {
    setState(() => _isLoading = true);
    await context.read<AdminProvider>().loadKpiAnalytics();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan KPI'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKpiData,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (_isLoading || adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.errorMessage != null) {
            return _buildErrorView(adminProvider.errorMessage!);
          }

          final analytics = adminProvider.kpiAnalytics;
          if (analytics == null) {
            return _buildEmptyView();
          }

          return RefreshIndicator(
            onRefresh: _loadKpiData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Section
                  _buildFilterSection(),
                  const SizedBox(height: 20),

                  // Statistics Overview
                  _buildStatisticsSection(analytics['statistics']),
                  const SizedBox(height: 20),

                  // Top Performers
                  _buildTopPerformersSection(analytics['top_employees']),
                  const SizedBox(height: 20),

                  // Active Prospects
                  _buildActiveProspectsSection(analytics['active_prospects']),
                  const SizedBox(height: 20),

                  // Pending Visits
                  _buildPendingVisitsSection(analytics['pending_visits']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading KPI data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKpiData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data KPI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Data KPI akan muncul setelah karyawan melakukan kunjungan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadKpiData,
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Periode',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period['value'],
                  child: Text(period['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
                _loadKpiData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic>? statistics) {
    if (statistics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Kunjungan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Grid stats
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Hari Ini',
              '${statistics['total_visits_today'] ?? 0}',
              Icons.today,
              Colors.blue,
            ),
            _buildStatCard(
              'Minggu Ini',
              '${statistics['total_visits_week'] ?? 0}',
              Icons.date_range,
              Colors.green,
            ),
            _buildStatCard(
              'Bulan Ini',
              '${statistics['total_visits_month'] ?? 0}',
              Icons.calendar_month,
              Colors.orange,
            ),
            _buildStatCard(
              'Tingkat Sukses',
              '${statistics['success_rate'] ?? 0}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Potential Value Card
        _buildPotentialValueCard(
          statistics['total_potential_value'] ?? 0,
          statistics['formatted_potential_value'] ?? 'Rp 0',
        ),

        const SizedBox(height: 16),

        // Visit Purpose Breakdown
        _buildVisitPurposeBreakdown(statistics['visits_by_purpose']),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialValueCard(dynamic value, String formattedValue) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Icon(Icons.account_balance_wallet, size: 40, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              'Total Nilai Potensial Bulan Ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitPurposeBreakdown(Map<String, dynamic>? breakdown) {
    if (breakdown == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breakdown Tujuan Kunjungan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPurposeItem(
                    'Prospecting',
                    breakdown['prospecting'] ?? 0,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildPurposeItem(
                    'Follow Up',
                    breakdown['follow_up'] ?? 0,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildPurposeItem(
                    'Closing',
                    breakdown['closing'] ?? 0,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeItem(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopPerformersSection(List<dynamic>? performers) {
    if (performers == null || performers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: performers.length > 5 ? 5 : performers.length,
          itemBuilder: (context, index) {
            final performer = performers[index];
            return _buildPerformerCard(performer, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildPerformerCard(Map<String, dynamic> performer, int rank) {
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor.withOpacity(0.2),
          child: Icon(rankIcon, color: rankColor),
        ),
        title: Text(
          performer['employee_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${performer['employee_id'] ?? 'N/A'}'),
            Text('${performer['visit_count'] ?? 0} kunjungan'),
            Text('Success Rate: ${performer['success_rate'] ?? 0}%'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '#$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
            Text(
              performer['formatted_potential'] ?? 'Rp 0',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildActiveProspectsSection(List<dynamic>? prospects) {
    if (prospects == null || prospects.isEmpty) {
      return _buildEmptySection(
        'Prospek Aktif',
        'Belum ada prospek aktif bulan ini',
        Icons.business_center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prospek Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${prospects.length} prospek',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prospects.length > 10 ? 10 : prospects.length,
          itemBuilder: (context, index) {
            final prospect = prospects[index];
            return _buildProspectCard(prospect);
          },
        ),
      ],
    );
  }

  Widget _buildProspectCard(Map<String, dynamic> prospect) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showProspectDetail(prospect),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.business, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prospect['client_name'] ?? 'Unknown Client',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'PIC: ${prospect['employee_name'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${prospect['visits_count'] ?? 0} kunjungan',
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(prospect['status']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (prospect['status'] ?? 'pending').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingVisitsSection(List<dynamic>? visits) {
    if (visits == null || visits.isEmpty) {
      return _buildEmptySection(
        'Kunjungan Pending',
        'Semua kunjungan sudah selesai',
        Icons.check_circle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kunjungan Pending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${visits.length} pending',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return _buildPendingVisitCard(visit);
          },
        ),
      ],
    );
  }

  Widget _buildPendingVisitCard(Map<String, dynamic> visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showVisitDetail(visit),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[100],
                child: Icon(Icons.schedule, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit['prospect_name'] ?? 'Unknown Prospect',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'PIC: ${visit['employee_name'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      visit['start_time'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title, String message, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showProspectDetail(Map<String, dynamic> prospect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prospect['client_name'] ?? 'Detail Prospek'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama Prospek', prospect['client_name'] ?? 'N/A'),
              _buildDetailRow(
                  'PIC Karyawan', prospect['employee_name'] ?? 'N/A'),
              _buildDetailRow('ID Karyawan', prospect['employee_id'] ?? 'N/A'),
              _buildDetailRow('Tujuan', prospect['visit_purpose'] ?? 'N/A'),
              _buildDetailRow('Status', prospect['status'] ?? 'N/A'),
              _buildDetailRow('Nilai Potensial',
                  prospect['formatted_potential_value'] ?? 'Rp 0'),
              _buildDetailRow('Alamat', prospect['address'] ?? 'N/A'),
              if (prospect['notes'] != null &&
                  prospect['notes'].toString().isNotEmpty)
                _buildDetailRow('Catatan', prospect['notes']),

              // Location button if coordinates are available
              if (prospect['latitude'] != null &&
                  prospect['longitude'] != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(
                      prospect['latitude'],
                      prospect['longitude'],
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text('Buka di Maps'),
                  ),
                ),
              ],
            ],
          ),
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

  void _showVisitDetail(Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(visit['prospect_name'] ?? 'Detail Kunjungan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Prospek', visit['prospect_name'] ?? 'N/A'),
              _buildDetailRow('PIC Karyawan', visit['employee_name'] ?? 'N/A'),
              _buildDetailRow('ID Karyawan', visit['employee_id'] ?? 'N/A'),
              _buildDetailRow('Tujuan', visit['visit_purpose'] ?? 'N/A'),
              _buildDetailRow('Waktu', visit['start_time'] ?? 'N/A'),
              _buildDetailRow('Alamat', visit['address'] ?? 'N/A'),

              // Location button if coordinates are available
              if (visit['latitude'] != null && visit['longitude'] != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(
                      visit['latitude'],
                      visit['longitude'],
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text('Buka di Maps'),
                  ),
                ),
              ],
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka Google Maps'),
        ),
      );
    }
  }
}
