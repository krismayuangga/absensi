import 'package:dio/dio.dart';
import '../config/app_config.dart';

class AdminContentService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  AdminContentService() {
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
        print('🔑 Auth token added to AdminContentService headers');
      }
    } catch (e) {
      print('❌ Auth token not available for AdminContentService: $e');
    }
  }

  // ANNOUNCEMENTS MANAGEMENT

  /// Get all announcements for admin management
  Future<Map<String, dynamic>> getAnnouncements({
    int page = 1,
    int perPage = 10,
    String? category,
    String? priority,
    String? search,
  }) async {
    try {
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (search != null) queryParams['search'] = search;

      print('🔄 Getting admin announcements...');
      final response = await _dio.get(
        '/info-media/announcements', // Use working endpoint
        queryParameters: queryParams,
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'pagination': response.data['pagination'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil data pengumuman',
      };
    } catch (e) {
      print('❌ Error getting announcements: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create new announcement
  Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    required String priority,
    required String category,
    String targetType = 'all',
    bool sendNotification = false,
    bool publishNow = true,
  }) async {
    try {
      _addAuthToken();

      final data = {
        'title': title,
        'content': content,
        'priority': priority,
        'category': category,
        'target_type': targetType,
        'send_notification': sendNotification,
        'publish_now': publishNow,
      };

      print('🔄 Creating announcement...');
      print('📤 Request data: $data');

      final response = await _dio.post(
        '/v1/admin/content/announcements', // Correct admin endpoint with v1 prefix
        data: data,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal membuat pengumuman',
      };
    } catch (e) {
      print('❌ Error creating announcement: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Error: $e',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update announcement
  Future<Map<String, dynamic>> updateAnnouncement({
    required int id,
    required String title,
    required String content,
    required String priority,
    required String category,
    String targetType = 'all',
    bool sendNotification = false,
    bool publishNow = true,
  }) async {
    try {
      _addAuthToken();

      final data = {
        'title': title,
        'content': content,
        'priority': priority,
        'category': category,
        'target_type': targetType,
        'send_notification': sendNotification,
        'publish_now': publishNow,
      };

      final response = await _dio.put(
        '/info-media/announcements/$id', // Use working endpoint
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengupdate pengumuman',
      };
    } catch (e) {
      print('❌ Error updating announcement: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete announcement
  Future<Map<String, dynamic>> deleteAnnouncement(int id) async {
    try {
      _addAuthToken();

      final response = await _dio
          .delete('/info-media/announcements/$id'); // Use working endpoint

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal menghapus pengumuman',
      };
    } catch (e) {
      print('❌ Error deleting announcement: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // MEDIA MANAGEMENT

  /// Get all media for admin management
  Future<Map<String, dynamic>> getMedia({
    int page = 1,
    int perPage = 20,
    String? type,
    String? category,
    String? search,
  }) async {
    try {
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      print('🔄 Getting admin media...');
      final response = await _dio.get(
        '/info-media/media',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'pagination': response.data['pagination'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil data media',
      };
    } catch (e) {
      print('❌ Error getting media: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Upload new media
  Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    required String title,
    String? description,
    required String category,
  }) async {
    try {
      _addAuthToken();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'title': title,
        'description': description ?? '',
        'category': category,
      });

      print('🔄 Uploading media...');
      final response = await _dio.post(
        '/info-media/media', // Use working endpoint
        data: formData,
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengupload media',
      };
    } catch (e) {
      print('❌ Error uploading media: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Error: $e',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete media
  Future<Map<String, dynamic>> deleteMedia(int id) async {
    try {
      _addAuthToken();

      final response =
          await _dio.delete('/info-media/media/$id'); // Use working endpoint

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal menghapus media',
      };
    } catch (e) {
      print('❌ Error deleting media: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // CONTENT STATISTICS

  /// Get content statistics
  Future<Map<String, dynamic>> getContentStats() async {
    try {
      _addAuthToken();

      final response =
          await _dio.get('/info-media/stats'); // Use working endpoint

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil statistik konten',
      };
    } catch (e) {
      print('❌ Error getting content stats: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
