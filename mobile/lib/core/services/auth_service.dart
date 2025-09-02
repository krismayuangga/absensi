import 'package:dio/dio.dart';
import '../config/app_config.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        // Store token in Hive
        final authBox = AppConfig.getBox(AppConfig.authBox);
        await authBox.put(AppConfig.tokenKey,
            data['token']); // Laravel returns 'token', not 'access_token'
        await authBox.put(AppConfig.userKey, data['user']);

        return {
          'success': true,
          'message': 'Login successful',
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Login failed',
          'errors': e.response?.data['errors'],
        };
      }

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Auto login for testing
  Future<Map<String, dynamic>> autoLoginForTesting() async {
    return await login('admin@test.com', '123456');
  }

  // Check if user is logged in
  bool isLoggedIn() {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      final token = authBox.get(AppConfig.tokenKey);
      return token != null;
    } catch (e) {
      return false;
    }
  }

  // Get stored token
  String? getToken() {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      return authBox.get(AppConfig.tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get stored user
  Map<String, dynamic>? getUser() {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      return authBox.get(AppConfig.userKey);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      await authBox.delete(AppConfig.tokenKey);
      await authBox.delete(AppConfig.userKey);
    } catch (e) {
      // Continue with logout even if clearing storage fails
    }
  }
}
