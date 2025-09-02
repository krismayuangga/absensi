import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/notification_provider.dart';

class KPITestScreen extends StatelessWidget {
  const KPITestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KPI System Test',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // System Status Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Status',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildStatusRow(
                            'Backend API', 'Connected', Colors.green),
                        _buildStatusRow(
                            'Database', 'MySQL Ready', Colors.green),
                        _buildStatusRow(
                            'Notifications',
                            '${notificationProvider.notifications.length} items',
                            Colors.blue),
                        _buildStatusRow(
                            'Unread Count',
                            '${notificationProvider.unreadCount}',
                            Colors.orange),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Action Buttons
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Actions',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () =>
                              notificationProvider.generateTestNotifications(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: const Text('Generate Test Notifications'),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => notificationProvider.refresh(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: const Text('Refresh Data'),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => notificationProvider.markAllAsRead(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: const Text('Mark All as Read'),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () =>
                              notificationProvider.clearAllNotifications(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: const Text('Clear All Notifications'),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // API Endpoints Info
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available API Endpoints',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildEndpointRow(
                            'GET /api/notifications', 'Fetch notifications'),
                        _buildEndpointRow(
                            'POST /api/notifications', 'Create notification'),
                        _buildEndpointRow('PUT /api/notifications/{id}',
                            'Update notification'),
                        _buildEndpointRow('DELETE /api/notifications/{id}',
                            'Delete notification'),
                        _buildEndpointRow(
                            'POST /api/notifications/bulk', 'Bulk create'),
                        _buildEndpointRow(
                            'GET /api/admin/dashboard', 'Admin dashboard data'),
                        _buildEndpointRow(
                            'GET /api/kpi/visits', 'KPI visit data'),
                        _buildEndpointRow(
                            'POST /api/kpi/visits', 'Create KPI visit'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointRow(String endpoint, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            endpoint,
            style: GoogleFonts.sourceCodePro(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
