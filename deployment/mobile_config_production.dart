class ApiConstants {
  // Production API URL for Domainesia hosting
  static const String baseUrl = 'https://yourdomain.com/api';

  // Development API URL (comment out in production)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';

  // API Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Employee endpoints
  static const String employees = '/employees';
  static const String employeeProfile = '/employees/profile';
  static const String updateProfile = '/employees/profile/update';

  // Attendance endpoints
  static const String checkin = '/attendance/checkin';
  static const String checkout = '/attendance/checkout';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceToday = '/attendance/today';

  // KPI endpoints
  static const String kpiTargets = '/kpi/targets';
  static const String kpiProgress = '/kpi/progress';
  static const String kpiUpdate = '/kpi/update';
  static const String kpiHistory = '/kpi/history';

  // Leave endpoints
  static const String leaveRequests = '/leave/requests';
  static const String submitLeave = '/leave/submit';
  static const String leaveHistory = '/leave/history';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';

  // File upload endpoints
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadMedia = '/upload/media';

  // Admin endpoints (for admin users)
  static const String adminDashboard = '/admin/dashboard';
  static const String adminEmployees = '/admin/employees';
  static const String adminAttendance = '/admin/attendance';
  static const String adminKpi = '/admin/kpi';
  static const String adminReports = '/admin/reports';

  // Request timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
