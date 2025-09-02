import 'package:dio/dio.dart';
import 'dart:async';
import '../config/app_config.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final authBox = AppConfig.getBox(AppConfig.authBox);
          final token = authBox.get(AppConfig.tokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              // Retry original request
              final clonedRequest = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(clonedRequest);
            } catch (e) {
              // Token refresh failed, user needs to login again
              _clearAuthData();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (birthDate != null) data['birth_date'] = birthDate;
      if (gender != null) data['gender'] = gender;

      final response = await _dio.put('/auth/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Attendance APIs
  Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final response = await _dio.get('/attendance/today');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required String photo,
    String? notes,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'photo': await MultipartFile.fromFile(photo),
        if (notes != null) 'notes': notes,
      });

      final response = await _dio.post('/attendance/clock-in', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required String photo,
    String? notes,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'photo': await MultipartFile.fromFile(photo),
        if (notes != null) 'notes': notes,
      });

      final response = await _dio.post('/attendance/clock-out', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAttendanceHistory({
    int page = 1,
    int limit = 10,
    int? month,
    int? year,
  }) async {
    try {
      final response = await _dio.get('/attendance/history', queryParameters: {
        'page': page,
        'limit': limit,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Leave APIs
  Future<Map<String, dynamic>> getLeaves({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get('/leaves/history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getLeaveBalance() async {
    try {
      final response = await _dio.get('/leaves/balance');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> submitLeave({
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachment,
    bool isHalfDay = false,
    String? halfDayPeriod,
    String? emergencyContact,
  }) async {
    try {
      // Use JSON data instead of FormData for now (file upload can be added later)
      final data = <String, dynamic>{
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        'is_half_day': isHalfDay,
        if (halfDayPeriod != null) 'half_day_period': halfDayPeriod,
        if (emergencyContact != null) 'emergency_contact': emergencyContact,
        // TODO: Handle file attachment later
      };

      final response = await _dio.post('/leaves/submit', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> cancelLeave(int leaveId) async {
    try {
      final response = await _dio.put('/leaves/cancel/$leaveId');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // KPI APIs
  Future<Map<String, dynamic>> getKPIDashboard() async {
    try {
      final response = await _dio.get('/kpi/dashboard');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMyKPIs() async {
    try {
      final response = await _dio.get('/kpi/my-kpis');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateKPIScore({
    required int kpiScoreId,
    required double actualValue,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/kpi/scores', data: {
        'kpi_score_id': kpiScoreId,
        'actual_value': actualValue,
        if (notes != null) 'notes': notes,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Private methods
  Future<void> _refreshToken() async {
    final authBox = AppConfig.getBox(AppConfig.authBox);
    final response = await _dio.post('/auth/refresh');

    if (response.data['success'] == true) {
      final newToken = response.data['data']['token'];
      await authBox.put(AppConfig.tokenKey, newToken);
    } else {
      throw Exception('Token refresh failed');
    }
  }

  void _clearAuthData() {
    final authBox = AppConfig.getBox(AppConfig.authBox);
    authBox.delete(AppConfig.tokenKey);
    authBox.delete(AppConfig.userKey);
  }

  String _handleDioError(DioException error) {
    if (error.response?.data != null) {
      final errorData = error.response!.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ?? 'An error occurred';
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
