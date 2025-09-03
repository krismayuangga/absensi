import 'package:dio/dio.dart';
import 'dart:io';
import '../config/app_config.dart';

class ProfileService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  ProfileService() {
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

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/v1/profile');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memuat profil',
      };
    } catch (e) {
      print('❌ Error getting user profile: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal memuat profil',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> profileData,
    File? profileImage,
  }) async {
    try {
      _addAuthToken();

      FormData formData = FormData();

      // Add profile data
      profileData.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add profile image if provided
      if (profileImage != null) {
        String fileName = profileImage.path.split('/').last;
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              profileImage.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.put('/v1/profile', data: formData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui profil',
      };
    } catch (e) {
      print('❌ Error updating profile: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal memperbarui profil',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _addAuthToken();

      final data = {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      };

      final response =
          await _dio.post('/v1/profile/change-password', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengubah password',
      };
    } catch (e) {
      print('❌ Error changing password: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal mengubah password',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      _addAuthToken();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response =
          await _dio.post('/v1/profile/upload-image', data: formData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengunggah foto profil',
      };
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Gagal mengunggah foto profil',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update notification settings
  Future<Map<String, dynamic>> updateNotificationSettings(bool enabled) async {
    try {
      _addAuthToken();

      final data = {
        'notifications_enabled': enabled,
      };

      final response =
          await _dio.put('/profile/notification-settings', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ??
            'Gagal memperbarui pengaturan notifikasi',
      };
    } catch (e) {
      print('❌ Error updating notification settings: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ??
              'Gagal memperbarui pengaturan notifikasi',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      _addAuthToken();

      final response = await _dio.get('/profile/statistics');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memuat statistik',
      };
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal memuat statistik',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      _addAuthToken();

      final data = {
        'password': password,
      };

      final response = await _dio.delete('/profile/delete-account', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal menghapus akun',
      };
    } catch (e) {
      print('❌ Error deleting account: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal menghapus akun',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get app version info
  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final response = await _dio.get('/app-info');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': 'Gagal memuat informasi aplikasi',
      };
    } catch (e) {
      print('❌ Error getting app info: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
