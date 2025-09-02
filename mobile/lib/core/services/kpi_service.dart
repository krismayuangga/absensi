import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class KpiService {
  final Dio _dio = Dio();
  static const String baseUrl = AppConfig.baseUrl;

  KpiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Add auth token to headers
  void _addAuthToken() {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      final token = authBox.get(AppConfig.tokenKey);
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Fallback for testing - skip auth for now
      print('Auth token not available: $e');
    }
  }

  // Get KPI statistics
  Future<Map<String, dynamic>> getKpiStats() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/kpi/stats');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil statistik KPI',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Log new visit
  Future<Map<String, dynamic>> logVisit({
    required String clientName,
    required String visitPurpose,
    required double latitude,
    required double longitude,
    String? address,
    required DateTime startTime,
    String? notes,
    XFile? photo,
  }) async {
    try {
      _addAuthToken();

      final formData = FormData.fromMap({
        'client_name': clientName,
        'visit_purpose': visitPurpose,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'start_time': startTime.toIso8601String(),
        'notes': notes,
      });

      if (photo != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.name,
            ),
          ),
        );
      }

      final response = await _dio.post('/kpi/visit/log', data: formData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mencatat kunjungan',
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Terjadi kesalahan',
          'errors': e.response?.data['errors'],
        };
      }

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Update visit result
  Future<Map<String, dynamic>> updateVisitResult({
    required int visitId,
    required String status,
    DateTime? endTime,
    double? potentialValue,
    DateTime? nextFollowUp,
    String? nextAction,
    int? probabilityScore,
  }) async {
    try {
      _addAuthToken();

      // Map Flutter status to backend expected values
      String backendStatus = status;
      if (status == 'potential') {
        backendStatus = 'success'; // Potential is treated as success with value
      } else if (status == 'pending') {
        // Don't update pending status, just return success
        return {
          'success': true,
          'message': 'Status pending - tidak ada perubahan',
        };
      }

      final data = {
        'status': backendStatus, // success or failed only
        'end_time': (endTime ?? DateTime.now()).toIso8601String(),
        'potential_value': potentialValue,
        'next_follow_up': nextFollowUp?.toIso8601String(),
        'next_action': nextAction,
        'probability_score': probabilityScore,
      };

      final response = await _dio.put('/kpi/visit/$visitId/result', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui hasil',
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Terjadi kesalahan',
          'errors': e.response?.data['errors'],
        };
      }

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get visit history
  Future<Map<String, dynamic>> getVisitHistory({String period = 'week'}) async {
    try {
      _addAuthToken();

      final response = await _dio
          .get('/kpi/visits/history', queryParameters: {'period': period});

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil riwayat kunjungan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get pending visits
  Future<Map<String, dynamic>> getPendingVisits() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/kpi/visits/pending');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil kunjungan pending',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
