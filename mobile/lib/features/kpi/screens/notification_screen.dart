import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A9B8E), // Ganti dari Colors.purple
        elevation: 0,
        title: Text(
          'Notifikasi',
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
          IconButton(
            onPressed: () => _markAllAsRead(),
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Tandai semua sebagai dibaca',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showNotificationSettings();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Pengaturan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Hapus Semua'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF4A9B8E),
              ),
            );
          }

          final notifications = notificationProvider.notifications;

          return Column(
            children: [
              // Summary Card
              Container(
                margin: EdgeInsets.all(12.w), // Kurangi dari 16.w ke 12.w
                padding: EdgeInsets.all(12.w), // Kurangi dari 16.w ke 12.w
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4A9B8E), const Color(0xFF45A29E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(12.r), // Kurangi dari 16.r ke 12.r
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w), // Kurangi dari 12.w ke 8.w
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            8.r), // Kurangi dari 12.r ke 8.r
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 20.w, // Kurangi dari 24.w ke 20.w
                      ),
                    ),
                    SizedBox(width: 12.w), // Kurangi dari 16.w ke 12.w
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Center',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_getUnreadCount(notifications)} notifikasi belum dibaca',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${notifications.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64.w,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Tidak ada notifikasi',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Semua notifikasi akan muncul di sini',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF4A9B8E),
                        onRefresh: () async {
                          await notificationProvider.loadNotifications();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationCard(notification, index);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = !notification['is_read'];
    final priority = notification['priority'] as String;

    Color priorityColor = Colors.grey;
    Color backgroundColor = Colors.white;

    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        backgroundColor = isUnread ? Colors.red.shade50 : Colors.white;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        backgroundColor = isUnread ? Colors.orange.shade50 : Colors.white;
        break;
      case 'low':
        priorityColor = Colors.blue;
        backgroundColor = isUnread ? Colors.blue.shade50 : Colors.white;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h), // Kurangi dari 12.h ke 8.h
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, index),
        borderRadius: BorderRadius.circular(10.r), // Kurangi dari 12.r ke 10.r
        child: Container(
          padding: EdgeInsets.all(12.w), // Kurangi dari 16.w ke 12.w
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(10.r), // Kurangi dari 12.r ke 10.r
            border: Border.all(
              color: isUnread
                  ? priorityColor.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: isUnread ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08), // Kurangi opacity shadow
                spreadRadius: 1,
                blurRadius: 4,
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
                      color: _getNotificationIcon(notification['type'])['color']
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification['type'])['icon'],
                      color:
                          _getNotificationIcon(notification['type'])['color'],
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification['message'],
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(notification['timestamp']),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          priority.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () => _dismissNotification(index),
                        child: Icon(
                          Icons.close,
                          size: 16.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return {'icon': Icons.schedule, 'color': Colors.orange};
      case 'target':
        return {'icon': Icons.flag, 'color': Colors.green};
      case 'pending':
        return {'icon': Icons.pending, 'color': Colors.amber};
      case 'success':
        return {'icon': Icons.check_circle, 'color': Colors.green};
      case 'weekly_report':
        return {'icon': Icons.analytics, 'color': Colors.blue};
      default:
        return {'icon': Icons.notifications, 'color': Colors.grey};
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    DateTime dateTime;
    if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      dateTime = DateTime.now();
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()}w yang lalu';
    }
  }

  int _getUnreadCount(List<Map<String, dynamic>> notifications) {
    return notifications.where((n) => !n['is_read']).length;
  }

  void _handleNotificationTap(Map<String, dynamic> notification, int index) {
    // Mark as read
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAsRead(notification['id']);

    // Handle different notification types
    switch (notification['type']) {
      case 'reminder':
        _handleReminderAction(notification);
        break;
      case 'pending':
        _handlePendingAction(notification);
        break;
      case 'target':
        _handleTargetAction(notification);
        break;
      case 'success':
        _handleSuccessAction(notification);
        break;
      case 'weekly_report':
        _handleReportAction(notification);
        break;
      default:
        _showNotificationDetail(notification);
    }
  }

  void _handleReminderAction(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Follow-up Reminder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            SizedBox(height: 16.h),
            Text(
              'Apa yang ingin Anda lakukan?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to visit logger or update result form
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9B8E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Follow-up Sekarang'),
          ),
        ],
      ),
    );
  }

  void _handlePendingAction(Map<String, dynamic> notification) {
    // Navigate to pending visits section in main KPI screen
    Navigator.of(context).pop();
  }

  void _handleTargetAction(Map<String, dynamic> notification) {
    _showNotificationDetail(notification);
  }

  void _handleSuccessAction(Map<String, dynamic> notification) {
    _showNotificationDetail(notification);
  }

  void _handleReportAction(Map<String, dynamic> notification) {
    // Navigate to report screen
    Navigator.of(context).pop();
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          notification['title'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _dismissNotification(int index) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final notification = provider.notifications[index];

    provider.deleteNotification(notification['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai sebagai dibaca'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Notifikasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider =
                  Provider.of<NotificationProvider>(context, listen: false);
              provider.clearAllNotifications();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi telah dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Follow-up Reminders'),
              subtitle: const Text('Pengingat untuk follow-up klien'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Target Notifications'),
              subtitle: const Text('Notifikasi pencapaian target'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Weekly Reports'),
              subtitle: const Text('Laporan mingguan otomatis'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
