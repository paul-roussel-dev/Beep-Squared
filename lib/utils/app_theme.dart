import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Application theme configuration following Material Design 3
class AppTheme {
  AppTheme._();

  // Default timing for adaptive themes
  static const int eveningStartHour = 19; // 7 PM
  static const int eveningEndHour = 7; // 7 AM

  /// Check if it's currently evening time
  static bool get isEveningTime =>
      isEveningTimeCustom(eveningStartHour, eveningEndHour);

  /// Check if it's evening time with custom hours
  static bool isEveningTimeCustom(int startHour, int endHour) {
    final now = DateTime.now();
    final currentHour = now.hour;

    if (startHour < endHour) {
      // Same day range (e.g., 10 AM to 6 PM)
      return currentHour >= startHour && currentHour < endHour;
    } else {
      // Overnight range (e.g., 7 PM to 7 AM)
      return currentHour >= startHour || currentHour < endHour;
    }
  }

  /// Get adaptive theme based on settings
  static ThemeData getAdaptiveThemeFromSettings() {
    return isEveningTime ? eveningTheme : dayTheme;
  }

  /// Get adaptive theme from current time or settings
  static ThemeData get adaptiveTheme {
    const int eveningHour = 19; // 7 PM
    final currentHour = DateTime.now().hour;
    return currentHour >= eveningHour ? eveningTheme : dayTheme;
  }

  /// Day theme configuration with blue backgrounds and light text
  static ThemeData get dayTheme {
    const ColorScheme dayColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3F51B5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF3F51B5), // Blue background
      onPrimaryContainer: Color(0xFFFFFFFF), // White text
      secondary: Color(0xFF5C6BC0),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF5C6BC0), // Blue background
      onSecondaryContainer: Color(0xFFFFFFFF), // White text
      tertiary: Color(0xFF7986CB),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF7986CB), // Blue background
      onTertiaryContainer: Color(0xFFFFFFFF), // White text
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      outline: Color(0xFF79747E),
      surface: Color(0xFF283593), // Blue surface
      onSurface: Color(0xFFFFFFFF), // White text
      surfaceContainerHighest: Color(0xFF3F51B5), // Blue surface variant
      onSurfaceVariant: Color(0xFFE8EAF6), // Light gray text
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFBDC2FF),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFF3F51B5),
    );

    return _buildTheme(dayColorScheme);
  }

  /// Evening theme configuration with orange backgrounds and light text
  static ThemeData get eveningTheme {
    const ColorScheme eveningColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFF8A50), // Orange primary
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFF8A50), // Orange background
      onPrimaryContainer: Color(0xFFFFFFFF), // White text
      secondary: Color(0xFFFFAB40), // Light orange secondary
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFAB40), // Orange background
      onSecondaryContainer: Color(0xFFFFFFFF), // White text
      tertiary: Color(0xFFFFCC80), // Lighter orange tertiary
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFCC80), // Orange background
      onTertiaryContainer: Color(0xFFFFFFFF), // White text
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      outline: Color(0xFF79747E),
      surface: Color(0xFFE65100), // Orange surface
      onSurface: Color(0xFFFFFFFF), // White text
      surfaceContainerHighest: Color(0xFFFF8A50), // Orange surface variant
      onSurfaceVariant: Color(0xFFFFF3E0), // Light orange text
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFFFCC80),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFFFF8A50),
    );

    return _buildTheme(eveningColorScheme);
  }

  /// Build theme with common configuration
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 3,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white; // Use white for consistency
          }
          return colorScheme.onSurface.withValues(alpha: 0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white.withValues(alpha: 0.3); // Use white with transparency
          }
          return colorScheme.onSurface.withValues(alpha: 0.2);
        }),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        thickness: 1,
        space: 16,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 8,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 16,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.2),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurface.withValues(alpha: 0.5);
        }),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
