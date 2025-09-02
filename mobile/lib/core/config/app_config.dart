import 'package:hive_flutter/hive_flutter.dart';

class AppConfig {
  // API Configuration
  static const String baseUrl =
      'http://10.0.2.2:8000/api/v1'; // Laravel backend API with v1 prefix
  static const String imageBaseUrl = 'http://10.0.2.2:8000/storage';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String biometricKey = 'biometric_enabled';

  // Hive Box Names
  static const String authBox = 'auth_box';
  static const String settingsBox = 'settings_box';
  static const String attendanceBox = 'attendance_box';

  // App Configuration
  static const String appName = 'Attendance & KPI';
  static const String appVersion = '1.0.0';

  // Location Configuration
  static const double defaultLatitude = -6.2608;
  static const double defaultLongitude = 106.7811;
  static const int locationAccuracy = 100; // meters

  // Initialize Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(authBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(attendanceBox);
  }

  // Get Hive Box
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }
}
