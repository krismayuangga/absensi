import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class NotificationService {
  static final Dio _dio = Dio();
  static const String baseUrl = AppConfig.baseUrl;

  static NotificationService? _instance;

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  NotificationService._() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // PRODUCTION VERSION - REAL API ONLY - NO MOCK DATA
  static Future<List<Map<String, dynamic>>> getNotifications({
    String? type,
    bool? unreadOnly,
  }) async {
    // Use REAL database endpoint instead of debug endpoint
    String debugUrl = baseUrl.replaceAll('/api/v1', '/api');
    String fullUrl =
        '$debugUrl/debug/notifications/real'; // Real database endpoint

    if (kDebugMode) {
      print(
          '🚀 PRODUCTION: Fetching REAL notifications from database: $fullUrl');
    }

    try {
      var queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (unreadOnly == true) queryParams['unread'] = 'true';

      final response = await _dio.get(
        fullUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final notifications =
            List<Map<String, dynamic>>.from(data['data'] ?? []);

        if (kDebugMode) {
          print(
              '✅ SUCCESS: Loaded ${notifications.length} REAL notifications from Laravel API');
          for (var notif in notifications) {
            print('   📬 ${notif['title']}: ${notif['message']}');
          }
        }
        return notifications;
      } else {
        if (kDebugMode) {
          print('❌ API Error - Status: ${response.statusCode}');
        }
        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PRODUCTION ERROR: $e');
        print('🚨 SERVER MUST BE RUNNING - No fallback data available');
      }
      // Production: Return empty list if API fails - NO MOCK DATA
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final response =
          await _dio.patch('$baseUrl/notifications/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.patch('$baseUrl/notifications/mark-all-read');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final response =
          await _dio.delete('$baseUrl/notifications/$notificationId');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      return false;
    }
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications(unreadOnly: true);
      return notifications.length;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to generate time ago string
  static String getTimeAgo(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Helper method to get notification icon
  static String getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return 'alarm';
      case 'target':
        return 'trending_up';
      case 'success':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'weekly_report':
        return 'assessment';
      default:
        return 'notifications';
    }
  }

  // Helper method to get priority color
  static String getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return '#ef4444';
      case 'medium':
        return '#f59e0b';
      case 'low':
        return '#10b981';
      default:
        return '#6b7280';
    }
  }
}
