import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n['is_read']).length;

  // Load notifications from API
  Future<void> loadNotifications({String? type, bool? unreadOnly}) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await NotificationService.getNotifications(
          type: type, unreadOnly: unreadOnly);
      _notifications = data;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading notifications: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await NotificationService.markAsRead(notificationId);
      if (success) {
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index >= 0) {
          _notifications[index]['is_read'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await NotificationService.markAllAsRead();
      if (success) {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success =
          await NotificationService.deleteNotification(notificationId);
      if (success) {
        _notifications.removeWhere((n) => n['id'] == notificationId);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Add new notification (for testing)
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Filter notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  // Filter notifications by priority
  List<Map<String, dynamic>> getNotificationsByPriority(String priority) {
    return _notifications.where((n) => n['priority'] == priority).toList();
  }

  // Get unread notifications only
  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => !n['is_read']).toList();
  }

  // Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    await loadNotifications();
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadNotifications();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Generate test notifications for demo
  void generateTestNotifications() {
    final testNotifications = [
      {
        'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'reminder',
        'title': 'Test Follow-up Reminder',
        'message': 'This is a test notification for follow-up reminder',
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
        'priority': 'high',
        'action_data': {
          'client_name': 'Test Client',
          'visit_id': 'test_visit_123',
        }
      },
      {
        'id': 'test_${DateTime.now().millisecondsSinceEpoch + 1}',
        'type': 'target',
        'title': 'Test Target Achievement',
        'message':
            'Congratulations! You have reached 90% of your monthly target',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
        'is_read': false,
        'priority': 'medium',
      }
    ];

    _notifications.insertAll(0, testNotifications);
    notifyListeners();
  }
}
