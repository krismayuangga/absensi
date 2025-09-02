import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  late Dio _dio;

  AttendanceService() {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token
          final authBox = AppConfig.getBox(AppConfig.authBox);
          final token = authBox.get(AppConfig.tokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - redirect to login
            // This will be handled by the provider
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get today's attendance
  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      // Check if user is authenticated first
      final authBox = AppConfig.getBox(AppConfig.authBox);
      final token = authBox.get(AppConfig.tokenKey);

      String endpoint;
      if (token == null) {
        // Use debug endpoint if not authenticated
        print('Using debug endpoint for attendance');
        endpoint = '${AppConfig.baseUrl}/debug/attendance/today';
      } else {
        endpoint = '${AppConfig.baseUrl}/attendance/today';
      }

      final response = await _dio.get(endpoint);

      if (response.data['success'] == true && response.data['data'] != null) {
        return AttendanceModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error loading attendance: $e');
      return null; // Don't throw exception, just return null
    }
  }

  /// Clock in with enhanced field work support
  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    String? address,
    File? photo,
    // Field work parameters
    String? workType,
    String? activityDescription,
    String? clientName,
    String? notes,
    // Anti-fake GPS parameters
    String? provider, // GPS provider info
    double? accuracy, // GPS accuracy
    String? networkInfo, // WiFi/Cell tower info
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'address': address ?? '',
        // Field work data
        if (workType != null) 'work_type': workType,
        if (activityDescription != null)
          'activity_description': activityDescription,
        if (clientName != null) 'client_name': clientName,
        if (notes != null) 'notes': notes,
        // Security data
        if (provider != null) 'location_provider': provider,
        if (accuracy != null) 'location_accuracy': accuracy,
        if (networkInfo != null) 'network_info': networkInfo,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (photo != null) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split('/').last,
          ),
        ));
      }

      final response = await _dio.post(
        '${AppConfig.baseUrl}/attendance/clock-in',
        data: formData,
      );

      if (response.data['success'] == true) {
        return AttendanceModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Clock in failed');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['message'] ?? 'Clock in failed';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to clock in: $e');
    }
  }

  /// Clock out
  Future<AttendanceModel> clockOut({
    required double latitude,
    required double longitude,
    String? address,
    File? photo,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'address': address ?? '',
      });

      if (photo != null) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split('/').last,
          ),
        ));
      }

      final response = await _dio.post(
        '${AppConfig.baseUrl}/attendance/clock-out',
        data: formData,
      );

      if (response.data['success'] == true) {
        return AttendanceModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Clock out failed');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = e.response?.data['message'] ?? 'Clock out failed';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to clock out: $e');
    }
  }

  /// Get attendance history
  Future<List<AttendanceModel>> getAttendanceHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/attendance/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'] ?? [];
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get attendance history: $e');
    }
  }

  /// Get attendance statistics
  Future<AttendanceStats> getAttendanceStats({
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '${AppConfig.baseUrl}/attendance/stats',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return AttendanceStats.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get stats');
      }
    } catch (e) {
      throw Exception('Failed to get attendance stats: $e');
    }
  }
}

class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double averageWorkingHours;
  final double attendanceRate;

  AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.averageWorkingHours,
    required this.attendanceRate,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      averageWorkingHours: (json['average_working_hours'] ?? 0).toDouble(),
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
    );
  }
}
