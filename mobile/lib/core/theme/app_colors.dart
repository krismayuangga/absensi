import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7BF0);
  static const Color primaryLight = Color(0xFF5AA7FF);
  static const Color primaryDark = Color(0xFF1A5DC7);

  // Secondary Colors
  static const Color secondary = Color(0xFF00C896);
  static const Color secondaryLight = Color(0xFF4DDDB4);
  static const Color secondaryDark = Color(0xFF00A076);

  // Success Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Error Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // Info Colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Shadow Colors
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowHeavy = Color(0x26000000);

  // Attendance specific colors
  static const Color checkIn = Color(0xFF22C55E);
  static const Color checkOut = Color(0xFFF97316);
  static const Color absent = Color(0xFFEF4444);
  static const Color late = Color(0xFFEAB308);

  // Leave specific colors
  static const Color leavePending = Color(0xFFF59E0B);
  static const Color leaveApproved = Color(0xFF10B981);
  static const Color leaveRejected = Color(0xFFEF4444);
  static const Color leaveCancelled = Color(0xFF6B7280);

  // Status colors
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF6B7280);
  static const Color busy = Color(0xFFF59E0B);
  static const Color away = Color(0xFFEF4444);

  // Gradient colors
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static LinearGradient secondaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static LinearGradient successGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  static LinearGradient warningGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, warningDark],
  );

  static LinearGradient errorGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorDark],
  );

  // Material Color Swatch for primary color
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2E7BF0,
    <int, Color>{
      50: Color(0xFFF0F6FF),
      100: Color(0xFFE0EBFF),
      200: Color(0xFFC7DCFF),
      300: Color(0xFFA3C5FF),
      400: Color(0xFF7CA1FF),
      500: Color(0xFF2E7BF0),
      600: Color(0xFF1A5DC7),
      700: Color(0xFF164BA3),
      800: Color(0xFF123A82),
      900: Color(0xFF0E2E68),
    },
  );
}
