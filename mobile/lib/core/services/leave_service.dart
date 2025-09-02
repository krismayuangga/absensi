import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/leave_model.dart';
import 'api_service.dart';

class LeaveService {
  late Dio _dio;
  late ApiService _apiService;

  LeaveService() {
    _dio = Dio();
    _apiService = ApiService();
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
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get leave balance
  Future<LeaveBalance> getLeaveBalance({int? year}) async {
    try {
      final response = await _apiService.getLeaveBalance();

      if (response['success'] == true) {
        return LeaveBalance.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to get leave balance');
      }
    } catch (e) {
      throw Exception('Failed to get leave balance: $e');
    }
  }

  /// Submit leave request
  Future<LeaveModel> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayPeriod,
    String? emergencyContact,
    File? attachment,
  }) async {
    try {
      final response = await _apiService.submitLeave(
        type: type,
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
        reason: reason,
        attachment: attachment?.path,
        isHalfDay: isHalfDay,
        halfDayPeriod: halfDayPeriod,
        emergencyContact: emergencyContact,
      );

      print('Leave service response: $response'); // Debug log

      if (response['success'] == true) {
        return LeaveModel.fromJson(response['data']);
      } else {
        throw Exception(
            response['message'] ?? 'Failed to submit leave request');
      }
    } catch (e) {
      print('Leave service error: $e'); // Debug log
      throw Exception('Failed to submit leave request: $e');
    }
  }

  /// Get leave history
  Future<List<LeaveModel>> getLeaveHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getLeaves(
        page: page,
        limit: limit,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data']['data'] ?? [];
        return data.map((json) => LeaveModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get leave history: $e');
    }
  }

  /// Cancel leave request
  Future<void> cancelLeaveRequest(int leaveId) async {
    try {
      final response = await _apiService.cancelLeave(leaveId);

      if (response['success'] != true) {
        throw Exception(
            response['message'] ?? 'Failed to cancel leave request');
      }
    } catch (e) {
      throw Exception('Failed to cancel leave request: $e');
    }
  }
}
