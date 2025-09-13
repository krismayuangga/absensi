import 'package:flutter/material.dart';
import 'dart:io';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  // User profile data
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Settings
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'id';
  String _selectedTheme = 'light';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;
  String get selectedTheme => _selectedTheme;

  /// Load user profile from API
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Loading user profile...');

      final result = await _service.getUserProfile();

      if (result['success'] == true) {
        _userProfile = result;
        _errorMessage = null;
        print('✅ Profile loaded successfully');
        print('👤 User: ${result['data']?['name']}');
      } else {
        _errorMessage = result['message'];
        print('❌ Profile load failed: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      print('❌ Profile load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? birthDate,
    String? address,
    String? gender,
    File? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Updating profile...');

      final result = await _service.updateProfile(
        name: name,
        phone: phone,
        birthDate: birthDate,
        address: address,
        gender: gender,
        profileImage: profileImage,
      );

      if (result['success'] == true) {
        // Update local data and reload from server
        if (result['data'] != null) {
          _userProfile = result;
        }
        _errorMessage = null;
        print('✅ Profile updated successfully');
        // Reload fresh data from server
        await loadUserProfile();
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Profile update failed: ${_errorMessage}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      print('❌ Profile update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Changing password...');

      final result = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Password changed successfully');
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Password change failed: ${_errorMessage}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error changing password: $e';
      print('❌ Password change error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Uploading profile image...');

      final result = await _service.uploadProfileImage(imageFile);

      if (result['success'] == true) {
        // Update local profile picture
        if (_userProfile != null && result['data'] != null) {
          _userProfile!['data']['avatar'] = result['data']['avatar'];
        }
        _errorMessage = null;
        print('✅ Profile image uploaded successfully');
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Profile image upload failed: ${_errorMessage}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error uploading image: $e';
      print('❌ Image upload error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(bool enabled) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.updateNotificationSettings(enabled);

      if (result['success'] == true) {
        _notificationsEnabled = enabled;
        _errorMessage = null;
        return true;
      } else {
        _errorMessage =
            result['message'] ?? 'Gagal memperbarui pengaturan notifikasi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update language setting
  void updateLanguageSetting(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  /// Update theme setting
  void updateThemeSetting(String theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  /// Get user statistics
  Future<void> loadUserStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getUserStatistics();
      if (result['success'] == true) {
        // Handle statistics data
      } else {
        _errorMessage = result['message'] ?? 'Gagal memuat statistik';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.deleteAccount(password);

      if (result['success'] == true) {
        _userProfile = null;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal menghapus akun';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear profile data
  void clearProfile() {
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
