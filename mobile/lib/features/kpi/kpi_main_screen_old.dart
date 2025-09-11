import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/kpi_provider.dart';
import '../../core/theme/app_theme.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
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
              child: CircularProgressIndicator(color: Color(0xFF4A9B8E)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await kpiProvider.initialize();
            },
            color: const Color(0xFF4A9B8E),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(),

                  SizedBox(height: 16.h),

                  // KPI Statistics Cards
                  _buildKpiStats(kpiProvider),

                  SizedBox(height: 16.h),

                  // Active Prospects Section (nama prospek yang bisa di-edit)
                  _buildActiveProspects(kpiProvider),

                  SizedBox(height: 16.h),

                  // Pending Visits Section
                  _buildPendingVisits(kpiProvider),

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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A9B8E), const Color(0xFF45A29E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A9B8E).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_location,
                  label: 'Catat Kunjungan',
                  onTap: () => _navigateToVisitLogger(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  onTap: () => _showAnalytics(),
                ),
              ),
              SizedBox(width: 8.w),
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
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 6.h),
        // 4 Cards in 2x2 Grid (more compact)
        Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                title: 'Hari Ini',
                value: kpiProvider.todayVisits.toString(),
                icon: Icons.today,
                color: const Color(0xFF4A9B8E),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildCompactStatCard(
                title: 'Minggu Ini',
                value: kpiProvider.weekVisits.toString(),
                icon: Icons.date_range,
                color: const Color(0xFF6BB6FF),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                title: 'Bulan Ini',
                value: kpiProvider.monthVisits.toString(),
                icon: Icons.calendar_month,
                color: const Color(0xFFFF9800),
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildCompactStatCard(
                title: 'Success Rate',
                value: kpiProvider.getFormattedSuccessRate(),
                icon: Icons.trending_up,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        // Potensi Nilai (smaller, more compact)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4CAF50), const Color(0xFF45A049)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child:
                    Icon(Icons.attach_money, color: Colors.white, size: 16.w),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potensi Nilai',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      kpiProvider.formattedPotentialValue,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
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

  Widget _buildCompactStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(icon, color: color, size: 12.w),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProspects(KPIProvider kpiProvider) {
    // Filter untuk mendapatkan prospek aktif dari data real
    // Prospek aktif = visits dengan status pending, potential, atau yang perlu follow up
    final activeProspects = kpiProvider.visitHistory
        .where((visit) {
          final status = visit['result_status'] ?? 'pending';
          // Prospek tetap aktif jika status = pending, potential, atau follow_up
          return status == 'pending' ||
              status == 'potential' ||
              (visit['next_action'] != null &&
                  visit['next_action'] == 'follow_up');
        })
        .map((visit) => {
              'client_name': visit['client_name'] ?? 'Klien Tidak Dikenal',
              'status': KPIProvider.getResultStatusLabel(
                  visit['result_status'] ?? 'pending'),
              'last_contact': visit['visited_at'] ?? 'Waktu tidak diketahui',
              'data': visit, // Keep original data for editing
            })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prospek Aktif',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (activeProspects.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  // Ambil prospek pertama untuk update
                  if (kpiProvider.pendingVisits.isNotEmpty) {
                    _navigateToResultUpdate(kpiProvider.pendingVisits.first);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A9B8E),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  minimumSize: Size(0, 28.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                icon: Icon(Icons.edit_note, size: 14.w),
                label: Text(
                  'Update Status',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        if (activeProspects.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_add,
                  size: 28.w,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Belum ada prospek aktif',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...activeProspects
              .take(4)
              .map((prospect) => _buildProspectCard(prospect))
              .toList(),
        if (activeProspects.length > 4)
          Center(
            child: TextButton.icon(
              onPressed: () => _showAllProspects(activeProspects),
              icon: Icon(Icons.expand_more,
                  size: 16.w, color: const Color(0xFF4A9B8E)),
              label: Text(
                'Lihat ${activeProspects.length - 4} prospek lainnya',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF4A9B8E),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProspectCard(Map<String, dynamic> prospect) {
    final hasData = prospect.containsKey('data');

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF4A9B8E).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
              color: const Color(0xFF4A9B8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.person,
              color: const Color(0xFF4A9B8E),
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prospect['client_name'] ?? 'Nama tidak dikenal',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        prospect['status'] ?? 'Menunggu',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '• ${prospect['last_contact'] ?? 'Waktu tidak diketahui'}',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A9B8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: IconButton(
              onPressed: () {
                // Semua prospek aktif pasti punya data sekarang
                final visitData = hasData
                    ? prospect['data']
                    : {
                        'id': 0,
                        'client_name': prospect['client_name'],
                        'result_status': 'pending',
                        'result_notes': '',
                        'potential_value': null,
                        'next_action': 'follow_up',
                        'visited_at': 'Waktu tidak diketahui',
                      };

                _navigateToResultUpdate(visitData);
              },
              icon: Icon(
                Icons.edit_note,
                color: const Color(0xFF4A9B8E),
                size: 18.w,
              ),
              constraints: BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.w,
              ),
              padding: EdgeInsets.zero,
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
        Text(
          'Kunjungan Pending',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        if (kpiProvider.pendingVisits.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 28.w,
                  color: Colors.green.shade400,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Semua kunjungan sudah selesai!',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orange.shade200),
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
                        '${kpiProvider.pendingVisits.length} kunjungan menunggu update',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Lihat di bagian "Prospek Aktif" untuk update status',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_upward,
                  color: const Color(0xFF4A9B8E),
                  size: 20.w,
                ),
              ],
            ),
          ),
      ],
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

  void _showAllProspects(List<Map<String, dynamic>> prospects) {
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
              'Semua Prospek Aktif',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: prospects.length,
                itemBuilder: (context, index) =>
                    _buildProspectCard(prospects[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
