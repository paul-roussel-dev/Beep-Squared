import 'package:flutter/material.dart';

/// Application color constants following Material Design 3
class AppColors {
  AppColors._();

  // === PRIMARY COLORS ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // === DAY THEME COLORS ===
  static const Color dayPrimary = Color(0xFF3F51B5);
  static const Color daySecondary = Color(0xFF5C6BC0);
  static const Color dayTertiary = Color(0xFF7986CB);
  static const Color daySurface = Color(0xFF283593);
  static const Color dayError = Color(0xFFD32F2F);
  static const Color dayErrorContainer = Color(0xFFFFCDD2);
  static const Color dayOutline = Color(0xFF79747E);
  static const Color dayInverseSurface = Color(0xFF313033);
  static const Color dayOnInverseSurface = Color(0xFFF4EFF4);
  static const Color dayInversePrimary = Color(0xFFBDC2FF);

  // === EVENING THEME COLORS ===
  static const Color eveningPrimary = Color(0xFFFF8A50);
  static const Color eveningSecondary = Color(0xFFFFAB40);
  static const Color eveningTertiary = Color(0xFFFFCC80);
  static const Color eveningSurface = Color(0xFFE65100);
  static const Color eveningError = Color(0xFFD32F2F);
  static const Color eveningErrorContainer = Color(0xFFFFCDD2);
  static const Color eveningOutline = Color(0xFF79747E);
  static const Color eveningInverseSurface = Color(0xFF313033);
  static const Color eveningOnInverseSurface = Color(0xFFF4EFF4);
  static const Color eveningInversePrimary = Color(0xFFFFCC80);

  // === SEMANTIC COLORS ===
  // These colors provide semantic meaning and maintain white text consistency
  static const Color textOnSurface = Color(
    0xFFFFFFFF,
  ); // Always white for consistency
  static const Color textPrimary = Color(0xFFFFFFFF); // Primary text color
  static const Color textSecondary = Color(0xFFE8E8E8); // Secondary text color
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // === NOTIFICATION COLORS ===
  static const Color notificationSuccess = Color(0xFF4CAF50);
  static const Color notificationError = Color(0xFFF44336);
  static const Color notificationWarning = Colors.orange;

  // === TRANSPARENCY LEVELS ===
  static const double alphaLow = 0.1;
  static const double alphaMedium = 0.2;
  static const double alphaHigh = 0.5;

  // === COMMON COLOR COMBINATIONS ===
  static Color whiteWithAlpha(double alpha) => white.withValues(alpha: alpha);
  static Color blackWithAlpha(double alpha) => black.withValues(alpha: alpha);
}
