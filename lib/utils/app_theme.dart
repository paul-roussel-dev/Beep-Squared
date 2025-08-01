import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  AppTheme._();

  static const int eveningStartHour = 20;
  static const int eveningEndHour = 6;

  static ThemeData getAdaptiveTheme() {
    return isEveningTime ? eveningTheme : dayTheme;
  }

  static bool get isEveningTime {
    final currentHour = DateTime.now().hour;
    return currentHour >= eveningStartHour || currentHour < eveningEndHour;
  }

  static bool isEveningTimeCustom(int startHour, int endHour) {
    final currentHour = DateTime.now().hour;
    return currentHour >= startHour || currentHour < endHour;
  }

  static ThemeData getAdaptiveThemeCustom(int eveningStart, int eveningEnd) {
    return isEveningTimeCustom(eveningStart, eveningEnd) ? eveningTheme : dayTheme;
  }

  static Future<ThemeData> getAdaptiveThemeFromSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eveningStart = prefs.getInt('evening_start_hour') ?? eveningStartHour;
      final eveningEnd = prefs.getInt('evening_end_hour') ?? eveningEndHour;
      return getAdaptiveThemeCustom(eveningStart, eveningEnd);
    } catch (e) {
      debugPrint('Error: $e');
      return getAdaptiveTheme();
    }
  }

  static ThemeData get dayTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3F51B5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF3F51B5),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF5C6BC0),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF5C6BC0),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF7986CB),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF7986CB),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      outline: Color(0xFF79747E),
      surface: Color(0xFF283593),
      onSurface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFF3F51B5),
      onSurfaceVariant: Color(0xFFE8EAF6),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFBDC2FF),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFF3F51B5),
    );
    return ThemeData(useMaterial3: true, colorScheme: colorScheme);
  }

  static ThemeData get eveningTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFF8A50),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFF8A50),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFAB40),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFAB40),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFFCC80),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFCC80),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      outline: Color(0xFF79747E),
      surface: Color(0xFFE65100),
      onSurface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFFF8A50),
      onSurfaceVariant: Color(0xFFFFF3E0),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFFFCC80),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFFFF8A50),
    );
    return ThemeData(useMaterial3: true, colorScheme: colorScheme);
  }

  static ThemeData get darkTheme => dayTheme;
}
