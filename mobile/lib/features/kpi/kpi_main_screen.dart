import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/kpi_provider.dart';
import 'widgets/visit_logger_form.dart';
import 'widgets/result_update_form.dart';
import 'screens/notification_screen.dart';
import 'screens/kpi_report_screen.dart';

class KPIMainScreen extends StatefulWidget {
  const KPIMainScreen({super.key});

  @override
  State<KPIMainScreen> createState() => _KPIMainScreenState();
}

class _KPIMainScreenState extends State<KPIMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KPIProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'KPI Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<KPIProvider>(context, listen: false).initialize();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<KPIProvider>(
        builder: (context, kpiProvider, child) {
          if (kpiProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await kpiProvider.initialize();
            },
            color: Colors.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(),

                  SizedBox(height: 20.h),

                  // KPI Statistics Cards
                  _buildKpiStats(kpiProvider),

                  SizedBox(height: 20.h),

                  // Pending Visits Section
                  _buildPendingVisits(kpiProvider),

                  SizedBox(height: 20.h),

                  // Recent Visit History
                  _buildRecentHistory(kpiProvider),

                  SizedBox(height: 80.h), // Bottom padding for navigation
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
            'Aksi Cepat',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_location,
                  label: 'Catat Kunjungan',
                  onTap: () => _navigateToVisitLogger(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_note,
                  label: 'Update Hasil',
                  onTap: () {
                    // Navigate to a screen showing all pending visits
                    // where user can select which visit to update
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Pilih kunjungan dari daftar di bawah untuk update hasil'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_active,
                  label: 'Notifikasi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  onTap: () => _showAnalytics(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24.w),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiStats(KPIProvider kpiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Kunjungan',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Hari Ini',
                value: kpiProvider.todayVisits.toString(),
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                title: 'Minggu Ini',
                value: kpiProvider.weekVisits.toString(),
                icon: Icons.date_range,
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Bulan Ini',
                value: kpiProvider.monthVisits.toString(),
                icon: Icons.calendar_month,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                title: 'Success Rate',
                value: kpiProvider.getFormattedSuccessRate(),
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child:
                    Icon(Icons.attach_money, color: Colors.white, size: 24.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potensi Nilai',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      kpiProvider.formattedPotentialValue,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.w),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVisits(KPIProvider kpiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kunjungan Pending',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (kpiProvider.pendingVisits.isNotEmpty)
              TextButton(
                onPressed: () =>
                    _showAllPendingVisits(kpiProvider.pendingVisits),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.purple,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (kpiProvider.pendingVisits.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 32.w,
                  color: Colors.green.shade400,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Semua kunjungan sudah selesai!',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...kpiProvider.pendingVisits
              .take(3)
              .map((visit) => _buildPendingVisitCard(visit))
              .toList(),
      ],
    );
  }

  Widget _buildPendingVisitCard(Map<String, dynamic> visit) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.schedule,
              color: Colors.orange.shade600,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit['client_name'] ?? 'Klien Tidak Dikenal',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  KPIProvider.getVisitPurposeLabel(
                      visit['visit_purpose'] ?? 'prospecting'),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToResultUpdate(visit),
            icon: Icon(
              Icons.edit,
              color: Colors.purple,
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(KPIProvider kpiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (kpiProvider.visitHistory.isNotEmpty)
              TextButton(
                onPressed: () => _showAllHistory(kpiProvider.visitHistory),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.purple,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (kpiProvider.visitHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 32.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Belum ada riwayat kunjungan',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...kpiProvider.visitHistory
              .take(5)
              .map((visit) => _buildHistoryCard(visit))
              .toList(),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> visit) {
    final status = visit['result_status'] ?? 'pending';
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

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
                  visit['client_name'] ?? 'Klien Tidak Dikenal',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      KPIProvider.getResultStatusLabel(status),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${visit['visited_at'] ?? 'Waktu tidak diketahui'}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (status == 'pending')
            IconButton(
              onPressed: () => _navigateToResultUpdate(visit),
              icon: Icon(
                Icons.edit,
                color: Colors.purple,
                size: 20.w,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToVisitLogger() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VisitLoggerForm(),
      ),
    );
  }

  void _navigateToResultUpdate(Map<String, dynamic> visit) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ResultUpdateForm(visit: visit),
      ),
    )
        .then((result) {
      if (result == true) {
        // Refresh data if result was updated
        Provider.of<KPIProvider>(context, listen: false).initialize();
      }
    });
  }

  void _showAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KpiReportScreen(),
      ),
    );
  }

  void _showAllPendingVisits(List<Map<String, dynamic>> visits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua Kunjungan Pending',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: visits.length,
                itemBuilder: (context, index) =>
                    _buildPendingVisitCard(visits[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllHistory(List<Map<String, dynamic>> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Kunjungan',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) =>
                    _buildHistoryCard(history[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
