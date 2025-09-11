import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/admin_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductivityAnalyticsScreen extends StatefulWidget {
  const ProductivityAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ProductivityAnalyticsScreen> createState() =>
      _ProductivityAnalyticsScreenState();
}

class _ProductivityAnalyticsScreenState
    extends State<ProductivityAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  String _selectedDepartment = 'all';
  bool _isLoading = false;

  final List<Map<String, String>> _periods = [
    {'value': 'today', 'label': 'Hari Ini'},
    {'value': 'week', 'label': 'Minggu Ini'},
    {'value': 'month', 'label': 'Bulan Ini'},
    {'value': 'quarter', 'label': 'Kuartal Ini'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductivityData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProductivityData() async {
    setState(() => _isLoading = true);

    // Load multiple data sources
    await Future.wait([
      context.read<AdminProvider>().loadDashboardStats(),
      context.read<AdminProvider>().loadKpiAnalytics(),
      context.read<AdminProvider>().loadEmployees(refresh: true),
    ]);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Produktivitas'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(
                text: 'Overview',
                icon: Icon(Icons.dashboard_outlined, size: 18)),
            Tab(text: 'Kehadiran', icon: Icon(Icons.access_time, size: 18)),
            Tab(text: 'KPI & Sales', icon: Icon(Icons.trending_up, size: 18)),
            Tab(text: 'Efisiensi', icon: Icon(Icons.speed, size: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProductivityData,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (_isLoading || adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter Section
              _buildFilterSection(),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(adminProvider),
                    _buildAttendanceTab(adminProvider),
                    _buildKpiTab(adminProvider),
                    _buildEfficiencyTab(adminProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Periode',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period['value'],
                  child: Text(period['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
                _loadProductivityData();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Departemen',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua Dept')),
                DropdownMenuItem(value: 'sales', child: Text('Sales')),
                DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() => _selectedDepartment = value!);
                _loadProductivityData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AdminProvider adminProvider) {
    final stats = adminProvider.dashboardStats;
    final kpiData = adminProvider.kpiAnalytics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Productivity Score
          _buildProductivityScoreCard(stats, kpiData),
          const SizedBox(height: 20),

          // Key Metrics Grid
          _buildKeyMetricsGrid(stats, kpiData),
          const SizedBox(height: 20),

          // Productivity Trend Chart
          _buildProductivityTrendCard(),
          const SizedBox(height: 20),

          // Top Insights
          _buildTopInsights(stats, kpiData),
        ],
      ),
    );
  }

  Widget _buildProductivityScoreCard(
      Map<String, dynamic>? stats, Map<String, dynamic>? kpiData) {
    // Calculate overall productivity score (0-100)
    double attendanceScore =
        stats != null ? (stats['persentase_kehadiran'] ?? 0).toDouble() : 0;
    double kpiScore = kpiData?['statistics']?['success_rate']?.toDouble() ?? 0;
    double overallScore = (attendanceScore + kpiScore) / 2;

    Color scoreColor;
    String scoreLabel;
    if (overallScore >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
    } else if (overallScore >= 60) {
      scoreColor = Colors.orange;
      scoreLabel = 'Good';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Needs Improvement';
    }

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Overall Productivity Score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Circular Progress Indicator
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: overallScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${overallScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          scoreLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: scoreColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreComponent('Kehadiran', attendanceScore, Colors.blue),
                _buildScoreComponent('KPI Success', kpiScore, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreComponent(String label, double score, Color color) {
    return Column(
      children: [
        Text(
          '${score.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsGrid(
      Map<String, dynamic>? stats, Map<String, dynamic>? kpiData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildMetricCard(
              'Avg Daily Attendance',
              '${stats?['hadir_hari_ini'] ?? 0}/${stats?['total_karyawan'] ?? 0}',
              Icons.people,
              Colors.blue,
              subtitle: '${stats?['persentase_kehadiran'] ?? 0}% rate',
            ),
            _buildMetricCard(
              'KPI Visits Today',
              '${kpiData?['statistics']?['total_visits_today'] ?? 0}',
              Icons.business_center,
              Colors.green,
              subtitle:
                  '${kpiData?['statistics']?['success_rate'] ?? 0}% success',
            ),
            _buildMetricCard(
              'Late Arrivals',
              '${stats?['terlambat_hari_ini'] ?? 0}',
              Icons.schedule,
              Colors.orange,
              subtitle: 'Today',
            ),
            _buildMetricCard(
              'Overtime Hours',
              '${stats?['lembur_hari_ini'] ?? 0}',
              Icons.access_time_filled,
              Colors.purple,
              subtitle: 'Today',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Trend (7 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          if (value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 85),
                        FlSpot(1, 88),
                        FlSpot(2, 82),
                        FlSpot(3, 90),
                        FlSpot(4, 86),
                        FlSpot(5, 75),
                        FlSpot(6, 80),
                      ],
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
  }

  Widget _buildTopInsights(
      Map<String, dynamic>? stats, Map<String, dynamic>? kpiData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.trending_up,
              'Attendance Performance',
              'Team attendance is ${stats?['persentase_kehadiran'] ?? 0}% - ${_getPerformanceLabel(stats?['persentase_kehadiran'] ?? 0)}',
              _getPerformanceColor(stats?['persentase_kehadiran'] ?? 0),
            ),
            _buildInsightItem(
              Icons.business_center,
              'KPI Success Rate',
              'KPI success rate is ${kpiData?['statistics']?['success_rate'] ?? 0}% - ${_getPerformanceLabel(kpiData?['statistics']?['success_rate'] ?? 0)}',
              _getPerformanceColor(
                  kpiData?['statistics']?['success_rate'] ?? 0),
            ),
            _buildInsightItem(
              Icons.schedule,
              'Punctuality',
              '${stats?['terlambat_hari_ini'] ?? 0} late arrivals today - ${_getPunctualityLabel(stats?['terlambat_hari_ini'] ?? 0)}',
              _getPunctualityColor(stats?['terlambat_hari_ini'] ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Attendance patterns, heatmaps, etc.
          _buildAttendanceHeatmap(),
          const SizedBox(height: 20),

          _buildAttendanceBreakdown(adminProvider),
        ],
      ),
    );
  }

  Widget _buildKpiTab(AdminProvider adminProvider) {
    final kpiData = adminProvider.kpiAnalytics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KPI & Sales Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // KPI efficiency metrics
          _buildKpiEfficiencyMetrics(kpiData),
          const SizedBox(height: 20),

          _buildConversionFunnel(kpiData),
        ],
      ),
    );
  }

  Widget _buildEfficiencyTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efficiency Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Time efficiency, resource utilization
          _buildEfficiencyMetrics(),
          const SizedBox(height: 20),

          _buildResourceUtilization(),
        ],
      ),
    );
  }

  // Helper methods for building specific sections
  Widget _buildAttendanceHeatmap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Heatmap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              child: const Center(
                child: Text('Heatmap visualization will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBreakdown(AdminProvider adminProvider) {
    final stats = adminProvider.dashboardStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'On Time',
                    '${(stats?['total_karyawan'] ?? 0) - (stats?['terlambat_hari_ini'] ?? 0)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildBreakdownItem(
                    'Late',
                    '${stats?['terlambat_hari_ini'] ?? 0}',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildBreakdownItem(
                    'Absent',
                    '${(stats?['total_karyawan'] ?? 0) - (stats?['hadir_hari_ini'] ?? 0)}',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count,
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
        ),
      ],
    );
  }

  Widget _buildKpiEfficiencyMetrics(Map<String, dynamic>? kpiData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KPI Efficiency Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildKpiMetric(
                  'Conversion Rate',
                  '${kpiData?['statistics']?['success_rate'] ?? 0}%',
                  Colors.green,
                ),
                _buildKpiMetric(
                  'Avg. Visit Value',
                  'Rp ${_formatNumber((kpiData?['statistics']?['total_potential_value'] ?? 0) / (kpiData?['statistics']?['total_visits_month'] ?? 1))}',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionFunnel(Map<String, dynamic>? kpiData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Conversion Funnel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Funnel visualization
            Container(
              height: 200,
              child: const Center(
                child: Text('Sales funnel chart will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Efficiency',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Time efficiency metrics
            Container(
              height: 150,
              child: const Center(
                child: Text('Time efficiency metrics will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceUtilization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resource Utilization',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Resource utilization charts
            Container(
              height: 150,
              child: const Center(
                child: Text(
                    'Resource utilization charts will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getPerformanceLabel(num value) {
    if (value >= 90) return 'Excellent';
    if (value >= 80) return 'Good';
    if (value >= 70) return 'Average';
    return 'Needs Improvement';
  }

  Color _getPerformanceColor(num value) {
    if (value >= 90) return Colors.green;
    if (value >= 80) return Colors.blue;
    if (value >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getPunctualityLabel(num lateCount) {
    if (lateCount == 0) return 'Perfect punctuality';
    if (lateCount <= 2) return 'Good punctuality';
    if (lateCount <= 5) return 'Average punctuality';
    return 'Needs improvement';
  }

  Color _getPunctualityColor(num lateCount) {
    if (lateCount == 0) return Colors.green;
    if (lateCount <= 2) return Colors.blue;
    if (lateCount <= 5) return Colors.orange;
    return Colors.red;
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
