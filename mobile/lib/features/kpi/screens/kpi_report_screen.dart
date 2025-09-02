import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/providers/kpi_provider.dart';

class KpiReportScreen extends StatefulWidget {
  const KpiReportScreen({super.key});

  @override
  State<KpiReportScreen> createState() => _KpiReportScreenState();
}

class _KpiReportScreenState extends State<KpiReportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KPIProvider>(context, listen: false)
          .loadReportData(_selectedPeriod);
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: Text(
          'Laporan KPI',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              Provider.of<KPIProvider>(context, listen: false)
                  .loadReportData(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('Minggu Ini'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Bulan Ini'),
              ),
              const PopupMenuItem(
                value: 'quarter',
                child: Text('Kuartal Ini'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Detail'),
          ],
        ),
      ),
      body: Consumer<KPIProvider>(
        builder: (context, kpiProvider, child) {
          if (kpiProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(kpiProvider),
              _buildChartsTab(kpiProvider),
              _buildDetailTab(kpiProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(KPIProvider kpiProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPeriodLabel(),
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ringkasan Performa KPI',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Total Kunjungan',
                        kpiProvider.monthVisits.toString(),
                        Icons.location_on,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildSummaryItem(
                        'Success Rate',
                        kpiProvider.getFormattedSuccessRate(),
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Potensi Nilai',
                        kpiProvider.formattedPotentialValue,
                        Icons.attach_money,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildSummaryItem(
                        'Avg per Visit',
                        _calculateAvgPerVisit(kpiProvider),
                        Icons.analytics,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Performance Metrics
          _buildPerformanceMetrics(kpiProvider),

          SizedBox(height: 20.h),

          // Top Clients
          _buildTopClients(kpiProvider),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(KPIProvider kpiProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metrik Performa',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow('Prospecting',
              _getVisitsByPurpose(kpiProvider, 'prospecting'), Colors.blue),
          SizedBox(height: 12.h),
          _buildMetricRow('Follow Up',
              _getVisitsByPurpose(kpiProvider, 'follow_up'), Colors.orange),
          SizedBox(height: 12.h),
          _buildMetricRow('Closing',
              _getVisitsByPurpose(kpiProvider, 'closing'), Colors.green),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, int count, Color color) {
    final total = Provider.of<KPIProvider>(context, listen: false).monthVisits;
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$count (${percentage.toStringAsFixed(1)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4.h,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopClients(KPIProvider kpiProvider) {
    final topClients = _getTopClients(kpiProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Klien',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ...topClients
              .take(5)
              .map((client) => _buildClientRow(client))
              .toList(),
          if (topClients.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 32.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Belum ada data klien',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClientRow(Map<String, dynamic> client) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.person,
              color: Colors.purple.shade600,
              size: 16.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name'] ?? 'Unknown Client',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${client['visits']} kunjungan',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (_safeParseDouble(client['potential_value']) > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Rp ${_formatCurrency(client['potential_value'])}',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartsTab(KPIProvider kpiProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Visit Trend Chart
          _buildVisitTrendChart(kpiProvider),
          SizedBox(height: 20.h),

          // Success Rate Pie Chart
          _buildSuccessRatePieChart(kpiProvider),
          SizedBox(height: 20.h),

          // Purpose Distribution
          _buildPurposeChart(kpiProvider),
        ],
      ),
    );
  }

  Widget _buildVisitTrendChart(KPIProvider kpiProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren Kunjungan',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateTrendData(kpiProvider),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRatePieChart(KPIProvider kpiProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Success Rate',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sections: _generateSuccessRateData(kpiProvider),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeChart(KPIProvider kpiProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Tujuan Kunjungan',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: _generatePurposeData(kpiProvider),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text('Prospecting',
                                style: GoogleFonts.inter(fontSize: 10.sp));
                          case 1:
                            return Text('Follow Up',
                                style: GoogleFonts.inter(fontSize: 10.sp));
                          case 2:
                            return Text('Closing',
                                style: GoogleFonts.inter(fontSize: 10.sp));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab(KPIProvider kpiProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Kunjungan',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          if (kpiProvider.visitHistory.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Belum ada data kunjungan',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...kpiProvider.visitHistory
                .map((visit) => _buildDetailVisitCard(visit))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildDetailVisitCard(Map<String, dynamic> visit) {
    final status = visit['result_status']?.toString() ?? 'pending';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;

    switch (status) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'potential':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
    }

    final clientName =
        visit['client_name']?.toString() ?? 'Klien Tidak Dikenal';
    final visitPurpose = visit['visit_purpose']?.toString() ?? 'prospecting';
    final address = visit['address']?.toString() ?? '';
    final visitedAt =
        visit['visited_at']?.toString() ?? 'Waktu tidak diketahui';
    final potentialValue = _safeParseDouble(visit['potential_value']);
    final notes = visit['notes']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      KPIProvider.getVisitPurposeLabel(visitPurpose),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  KPIProvider.getResultStatusLabel(status),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (address.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16.w, color: Colors.grey.shade600),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    address,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            children: [
              Icon(Icons.access_time, size: 16.w, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Text(
                visitedAt,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (potentialValue > 0) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.attach_money,
                    size: 16.w, color: Colors.green.shade600),
                SizedBox(width: 6.w),
                Text(
                  'Potensi: Rp ${_formatCurrency(potentialValue)}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                notes,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Minggu Ini';
      case 'month':
        return 'Bulan Ini';
      case 'quarter':
        return 'Kuartal Ini';
      default:
        return 'Periode';
    }
  }

  String _calculateAvgPerVisit(KPIProvider kpiProvider) {
    if (kpiProvider.monthVisits == 0) return 'Rp 0';

    final potential = kpiProvider.potentialValue;
    final visits = kpiProvider.monthVisits;

    if (visits <= 0 || potential <= 0) return 'Rp 0';

    final avg = potential / visits;
    return 'Rp ${_formatCurrency(avg)}';
  }

  int _getVisitsByPurpose(KPIProvider kpiProvider, String purpose) {
    // Use pre-calculated data from backend instead of filtering visitHistory
    return kpiProvider.visitsByPurpose[purpose] ?? 0;
  }

  List<Map<String, dynamic>> _getTopClients(KPIProvider kpiProvider) {
    final Map<String, Map<String, dynamic>> clientMap = {};

    for (final visit in kpiProvider.visitHistory) {
      final clientName = visit['client_name']?.toString() ?? 'Unknown';
      final potentialValue = _safeParseDouble(visit['potential_value']);

      if (clientMap.containsKey(clientName)) {
        clientMap[clientName]!['visits'] =
            (clientMap[clientName]!['visits'] as int) + 1;
        clientMap[clientName]!['potential_value'] =
            (clientMap[clientName]!['potential_value'] as double) +
                potentialValue;
      } else {
        clientMap[clientName] = {
          'name': clientName,
          'visits': 1,
          'potential_value': potentialValue,
        };
      }
    }

    final clients = clientMap.values.toList();
    clients.sort((a, b) => (b['visits'] as int).compareTo(a['visits'] as int));
    return clients;
  }

  // Helper method for safe double parsing
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  List<FlSpot> _generateTrendData(KPIProvider kpiProvider) {
    // Simulate trend data - in real app, this would come from API
    return [
      FlSpot(0, kpiProvider.todayVisits.toDouble()),
      FlSpot(1, (kpiProvider.todayVisits + 2).toDouble()),
      FlSpot(2, (kpiProvider.todayVisits + 1).toDouble()),
      FlSpot(3, (kpiProvider.todayVisits + 3).toDouble()),
      FlSpot(4, (kpiProvider.todayVisits + 2).toDouble()),
      FlSpot(5, (kpiProvider.todayVisits + 4).toDouble()),
      FlSpot(6, kpiProvider.weekVisits.toDouble()),
    ];
  }

  List<PieChartSectionData> _generateSuccessRateData(KPIProvider kpiProvider) {
    final successCount = kpiProvider.visitHistory
        .where((visit) => visit['result_status'] == 'success')
        .length;
    final failedCount = kpiProvider.visitHistory
        .where((visit) => visit['result_status'] == 'failed')
        .length;
    final pendingCount = kpiProvider.visitHistory
        .where((visit) => visit['result_status'] == 'pending')
        .length;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: successCount.toDouble(),
        title: '$successCount\nBerhasil',
        radius: 50,
        titleStyle: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: failedCount.toDouble(),
        title: '$failedCount\nGagal',
        radius: 50,
        titleStyle: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: pendingCount.toDouble(),
        title: '$pendingCount\nPending',
        radius: 50,
        titleStyle: GoogleFonts.inter(fontSize: 10.sp, color: Colors.white),
      ),
    ];
  }

  List<BarChartGroupData> _generatePurposeData(KPIProvider kpiProvider) {
    final prospectingCount = _getVisitsByPurpose(kpiProvider, 'prospecting');
    final followUpCount = _getVisitsByPurpose(kpiProvider, 'follow_up');
    final closingCount = _getVisitsByPurpose(kpiProvider, 'closing');

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: prospectingCount.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: followUpCount.toDouble(),
            color: Colors.orange,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: closingCount.toDouble(),
            color: Colors.green,
            width: 20,
          ),
        ],
      ),
    ];
  }

  String _formatCurrency(dynamic amount) {
    double value = 0.0;

    if (amount == null) return '0';

    if (amount is double) {
      value = amount;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else {
      return '0';
    }

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
