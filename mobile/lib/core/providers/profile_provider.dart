import 'package:flutter/material.dart';
import 'dart:io';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;

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

  /// Load user profile data
  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.getUserProfile();
      if (result['success'] == true) {
        _userProfile = result['data'];
        debugPrint('✅ Real user profile loaded from API');
      } else {
        _setError(result['message'] ?? 'Gagal memuat profil');
        debugPrint('❌ Failed to load profile: ${result['message']}');
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('❌ Error loading user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required Map<String, dynamic> profileData,
    File? profileImage,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.updateProfile(
        profileData: profileData,
        profileImage: profileImage,
      );

      if (result['success'] == true) {
        _userProfile = result['data'];
        return true;
      } else {
        _setError(result['message'] ?? 'Gagal memperbarui profil');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (newPassword != confirmPassword) {
        _setError('Password baru tidak cocok');
        return false;
      }

      final result = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _setError(result['message'] ?? 'Gagal mengubah password');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error changing password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.uploadProfileImage(imageFile);

      if (result['success'] == true) {
        _userProfile?['avatar'] = result['data']['avatar_url'];
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Gagal mengunggah foto profil');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error uploading profile image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(bool enabled) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.updateNotificationSettings(enabled);

      if (result['success'] == true) {
        _notificationsEnabled = enabled;
        return true;
      } else {
        _setError(
            result['message'] ?? 'Gagal memperbarui pengaturan notifikasi');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error updating notification settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update language setting
  void updateLanguageSetting(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
    // TODO: Implement actual language change logic
  }

  /// Update theme setting
  void updateThemeSetting(String theme) {
    _selectedTheme = theme;
    notifyListeners();
    // TODO: Implement actual theme change logic
  }

  /// Get user statistics
  Future<void> loadUserStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.getUserStatistics();
      if (result['success'] == true) {
        // Handle statistics data
        // This could be used for showing user performance metrics
      } else {
        _setError(result['message'] ?? 'Gagal memuat statistik');
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error loading user statistics: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _service.deleteAccount(password);

      if (result['success'] == true) {
        _userProfile = null;
        return true;
      } else {
        _setError(result['message'] ?? 'Gagal menghapus akun');
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      debugPrint('Error deleting account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
