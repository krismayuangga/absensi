import 'package:dio/dio.dart';
import '../config/app_config.dart';

class InfoMediaService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://kpi.kinerja.io/api';

  InfoMediaService() {
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
      print('Auth token not available: $e');
    }
  }

  // ANNOUNCEMENTS

  /// Get announcements list
  Future<Map<String, dynamic>> getAnnouncements({
    int page = 1,
    int perPage = 10,
    String? category,
    String? priority,
  }) async {
    try {
      print('🔄 Starting getAnnouncements API call...');
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;

      print('🌐 Making request to: ${baseUrl}/info-media/announcements');
      print('📊 Query params: $queryParams');

      final response = await _dio.get(
        '/info-media/announcements',
        queryParameters: queryParams,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print(
            '✅ SUCCESS: Loaded ${response.data['data']?.length ?? 0} announcements');
        return {
          'success': true,
          'data': response.data['data'],
          'pagination': response.data['pagination'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil pengumuman',
      };
    } catch (e) {
      print('❌ Error loading announcements: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get single announcement details
  Future<Map<String, dynamic>> getAnnouncementDetails(int id) async {
    try {
      _addAuthToken();

      print('🌐 Fetching announcement details for ID: $id');
      print(
          '🔗 Request URL: ${_dio.options.baseUrl}/info-media/announcements/$id');
      print('🔑 Auth header: ${_dio.options.headers['Authorization']}');

      final response = await _dio.get('/info-media/announcements/$id');

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ SUCCESS: Loaded announcement details for ID: $id');
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Pengumuman tidak ditemukan',
      };
    } catch (e) {
      print('❌ Error loading announcement details: $e');
      if (e is DioException) {
        print('🚨 Dio Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Message: ${e.message}');
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add comment to announcement (Legacy method - use addComment instead)
  Future<Map<String, dynamic>> addAnnouncementComment(int id, String comment,
      {int? parentId}) async {
    try {
      _addAuthToken();

      final data = {
        'comment': comment,
        if (parentId != null) 'parent_id': parentId,
      };

      final response =
          await _dio.post('/info-media/announcements/$id/comments', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal menambahkan komentar',
        'errors': response.data['errors'],
      };
    } catch (e) {
      print('❌ Error adding comment: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Gagal menambahkan komentar',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Toggle like on comment
  Future<void> toggleCommentLike(int commentId) async {
    try {
      _addAuthToken();

      await _dio.post('/v1/info-media/comments/$commentId/like');
    } catch (e) {
      print('❌ Error toggling comment like: $e');
      throw Exception('Gagal mengubah like komentar: $e');
    }
  }

  /// Get announcement categories
  Future<Map<String, dynamic>> getAnnouncementCategories() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/v1/announcements/categories');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil kategori',
      };
    } catch (e) {
      print('❌ Error loading categories: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // MEDIA GALLERY

  /// Get media gallery
  Future<Map<String, dynamic>> getMediaGallery({
    int page = 1,
    int perPage = 20,
    String? type,
    String? category,
  }) async {
    try {
      print('🔄 Starting getMediaGallery API call...');
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;

      print('🌐 Making request to: ${baseUrl}/info-media/media');
      print('📊 Query params: $queryParams');

      final response = await _dio.get(
        '/info-media/media',
        queryParameters: queryParams,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print(
            '✅ SUCCESS: Loaded ${response.data['data']?.length ?? 0} media items');
        return {
          'success': true,
          'data': response.data['data'],
          'pagination': response
              .data['meta'], // Media uses 'meta' instead of 'pagination'
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil galeri media',
      };
    } catch (e) {
      print('❌ Error loading media gallery: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get single media details
  Future<Map<String, dynamic>> getMediaDetails(int id) async {
    try {
      _addAuthToken();

      final response = await _dio.get('/info-media/media/$id');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Media tidak ditemukan',
      };
    } catch (e) {
      print('❌ Error loading media details: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Download media file
  Future<Map<String, dynamic>> downloadMedia(int id) async {
    try {
      _addAuthToken();

      final response = await _dio.get('/v1/media/$id/download');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengunduh file',
      };
    } catch (e) {
      print('❌ Error downloading media: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get media categories
  Future<Map<String, dynamic>> getMediaCategories() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/v1/media/categories');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil kategori media',
      };
    } catch (e) {
      print('❌ Error loading media categories: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // PUSH NOTIFICATIONS

  /// Register device token for push notifications
  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    required String platform, // 'android' or 'ios'
    String? appVersion,
  }) async {
    try {
      _addAuthToken();

      final data = {
        'device_token': token,
        'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
      };

      final response =
          await _dio.post('/v1/push-notifications/register-token', data: data);

      if (response.statusCode == 200) {
        print('✅ SUCCESS: Registered push notification token');
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message':
            response.data['message'] ?? 'Gagal mendaftarkan token notifikasi',
      };
    } catch (e) {
      print('❌ Error registering push token: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Send test push notification
  Future<Map<String, dynamic>> sendTestNotification({
    required String title,
    required String body,
  }) async {
    try {
      _addAuthToken();

      final data = {
        'title': title,
        'body': body,
      };

      final response =
          await _dio.post('/v1/push-notifications/test', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengirim notifikasi test',
      };
    } catch (e) {
      print('❌ Error sending test notification: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // LIKE & COMMENT METHODS

  /// Toggle like on announcement
  Future<Map<String, dynamic>> toggleAnnouncementLike(
      int announcementId) async {
    try {
      _addAuthToken();

      final response =
          await _dio.post('/v1/info-media/announcements/$announcementId/like');

      if (response.statusCode == 200) {
        return response.data;
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengubah like',
      };
    } catch (e) {
      print('❌ Error toggling announcement like: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Add comment to announcement
  Future<Map<String, dynamic>?> addComment(int announcementId, String content,
      {int? parentId}) async {
    try {
      _addAuthToken();

      final data = {
        'comment':
            content, // Changed from 'content' to 'comment' to match Laravel validation
        if (parentId != null) 'parent_id': parentId,
      };

      print('🔄 Adding comment to announcement $announcementId');
      print('📤 Request data: $data');

      final response = await _dio.post(
          '/v1/info-media/announcements/$announcementId/comments',
          data: data);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      print('❌ Error adding comment: $e');
      throw Exception('Gagal menambahkan komentar: $e');
    }
  }

  /// Delete comment
  Future<void> deleteComment(int commentId) async {
    try {
      _addAuthToken();

      await _dio.delete('/v1/info-media/comments/$commentId');
    } catch (e) {
      print('❌ Error deleting comment: $e');
      throw Exception('Gagal menghapus komentar: $e');
    }
  }
}
