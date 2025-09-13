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
        print('🔑 Using token: ${token.substring(0, 50)}...');
      } else {
        print('❌ No token found in storage');
      }
    } catch (e) {
      print('❌ Auth token error: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('🔄 Getting user profile...');
      _addAuthToken();

      final response = await _dio.get('/v1/profile');

      print('✅ Profile response: ${response.statusCode}');
      print('📊 Profile data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
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
    String? name,
    String? phone,
    String? birthDate,
    String? address,
    String? gender,
    File? profileImage,
  }) async {
    try {
      print('🔄 Updating profile...');
      print('📷 Profile image parameter: ${profileImage?.path ?? "NULL"}');
      _addAuthToken();

      // If there's a profile image, use FormData, otherwise use JSON
      if (profileImage != null) {
        print('📤 Using FormData because image is provided');
        print('📁 Image path: ${profileImage.path}');
        print('📏 Image exists: ${await profileImage.exists()}');
        FormData formData = FormData();

        // Add profile data
        if (name != null) formData.fields.add(MapEntry('name', name));
        if (phone != null) formData.fields.add(MapEntry('phone', phone));
        if (birthDate != null)
          formData.fields.add(MapEntry('birth_date', birthDate));
        if (address != null) formData.fields.add(MapEntry('address', address));
        if (gender != null) formData.fields.add(MapEntry('gender', gender));

        print(
            '📤 Sending FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');

        // Add profile image
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

        // Add _method field for Laravel method spoofing
        formData.fields.add(MapEntry('_method', 'PUT'));

        final response = await _dio.post(
          '/v1/profile',
          data: formData,
          options: Options(
            headers: {
              'Authorization': _dio.options.headers['Authorization'],
              // Don't set Content-Type, let Dio handle it for FormData
            },
          ),
        );

        print('✅ Update response: ${response.statusCode}');
        print('📊 Update result: ${response.data}');

        if (response.statusCode == 200) {
          return response.data;
        }
      } else {
        print('📝 Using JSON because no image provided');
        // Use JSON for profile data without image
        Map<String, dynamic> updateData = {};

        if (name != null) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;
        if (birthDate != null) updateData['birth_date'] = birthDate;
        if (address != null) updateData['address'] = address;
        if (gender != null) updateData['gender'] = gender;

        print('📤 Sending JSON data: $updateData');

        final response = await _dio.put('/v1/profile', data: updateData);

        print('✅ Update response: ${response.statusCode}');
        print('📊 Update result: ${response.data}');

        if (response.statusCode == 200) {
          return response.data;
        }
      }

      // If we reach here, something went wrong
      return {
        'success': false,
        'message': 'Gagal memperbarui profil',
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
      print('🔄 Changing password...');
      _addAuthToken();

      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      };

      final response = await _dio.post('/profile/change-password', data: data);

      print('✅ Password change response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data;
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
      print('🔄 Uploading profile image...');
      _addAuthToken();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post('/profile/upload-image', data: formData);

      print('✅ Upload response: ${response.statusCode}');
      print('📊 Upload result: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
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
