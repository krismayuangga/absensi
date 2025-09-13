import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  final ApiService _apiService = ApiService();

  // Constructor
  AuthProvider() {
    // Remove auto-loading stored auth for production
    // _loadStoredAuth(); // This will be called manually after successful login
  }

  // Load stored authentication data (for manual check)
  Future<void> loadStoredAuth() async {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      _token = authBox.get(AppConfig.tokenKey);

      if (_token != null) {
        final userData = authBox.get(AppConfig.userKey);
        if (userData != null && userData is Map) {
          _user = UserModel.fromJson(Map<String, dynamic>.from(userData));

          // Try to validate token, but don't fail if offline
          try {
            final isTokenValid = await _validateToken();
            if (!isTokenValid) {
              debugPrint('Token validation failed, clearing stored auth');
              await _clearStoredAuth();
              return;
            }
          } catch (e) {
            // If network error, assume token is still valid for offline usage
            debugPrint(
                'Network error during token validation, allowing offline login: $e');
          }

          notifyListeners();
        }
      }
    } catch (e) {
      // Clear corrupted stored auth data
      debugPrint('Error loading stored auth: $e');
      await _clearStoredAuth();
    }
  }

  // Validate token by making a test API call
  Future<bool> _validateToken() async {
    if (_token == null) return false;

    try {
      // Try to fetch profile to validate token
      final response = await _apiService.getProfile();
      return response['success'] == true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  // Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    final authBox = AppConfig.getBox(AppConfig.authBox);
    await authBox.clear();
    _token = null;
    _user = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.login(email, password);

      // Debug logging
      debugPrint('Login response: $response');

      if (response['success'] == true) {
        // Handle direct response format from Laravel API
        _token = response['token'];

        // Debug log user data
        debugPrint('User data: ${response['user']}');

        _user = UserModel.fromJson(response['user']);

        // Store in local storage
        final authBox = AppConfig.getBox(AppConfig.authBox);
        await authBox.put(AppConfig.tokenKey, _token);
        await authBox.put(AppConfig.userKey, _user!.toJson());

        debugPrint('Login successful - Token: ${_token?.substring(0, 20)}...');
        debugPrint('User: ${_user?.name} (${_user?.role})');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        debugPrint('Login failed: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception in login: ${e.toString()}');
      debugPrint('Exception type: ${e.runtimeType}');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.updateProfile(
        name: name,
        phone: phone,
        address: address,
        birthDate: birthDate,
        gender: gender,
      );

      if (response['success'] == true) {
        // Update user data
        final updatedData = response['data'];
        _user = _user?.copyWith(
          name: updatedData['name'],
          phone: updatedData['phone'],
          address: address,
          birthDate: birthDate,
          gender: gender,
        );

        // Update local storage
        final authBox = AppConfig.getBox(AppConfig.authBox);
        await authBox.put(AppConfig.userKey, _user!.toJson());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Password change failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    debugPrint('Starting logout process...');

    try {
      // Call API to logout
      await _apiService.logout();
      debugPrint('Logout API call successful');
    } catch (e) {
      // Continue with local logout even if API call fails
      debugPrint('Logout API error: $e');
    }

    // Clear local data
    _user = null;
    _token = null;
    _errorMessage = null;

    // Clear storage
    final authBox = AppConfig.getBox(AppConfig.authBox);
    await authBox.delete(AppConfig.tokenKey);
    await authBox.delete(AppConfig.userKey);

    debugPrint('Logout completed. isAuthenticated: $isAuthenticated');
    notifyListeners();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.refreshToken();

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];

        // Update stored token
        final authBox = AppConfig.getBox(AppConfig.authBox);
        await authBox.put(AppConfig.tokenKey, _token);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  // Get profile from server
  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.getProfile();

      if (response['success'] == true) {
        _user = UserModel.fromJson(response['data']);

        // Update stored user data
        final authBox = AppConfig.getBox(AppConfig.authBox);
        await authBox.put(AppConfig.userKey, _user!.toJson());

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
