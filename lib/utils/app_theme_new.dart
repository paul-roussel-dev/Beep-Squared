import 'package:flutter/material.dart';

/// Application theme configuration following Material Design 3
///
/// This class provides a centralized theme configuration for the entire app,
/// ensuring consistency across all screens and components.
/// Includes adaptive color scheme that changes from blue (day) to orange (evening)
/// to promote better sleep patterns.
class AppTheme {
  AppTheme._();

  /// Evening theme transition time (8:00 PM)
  static const int eveningHour = 20;

  /// Get the appropriate theme based on current time
  static ThemeData getAdaptiveTheme() {
    final currentHour = DateTime.now().hour;
    return currentHour >= eveningHour ? eveningTheme : dayTheme;
  }

  /// Check if it's evening time (after 8 PM)
  static bool get isEveningTime {
    return DateTime.now().hour >= eveningHour;
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
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurfaceVariant,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return const Color(0xFFE0E0E0);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer.withValues(alpha: 0.5);
          }
          return const Color(0xFF616161);
        }),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        sizeConstraints: const BoxConstraints.tightFor(width: 56, height: 56),
      ),
    );
  }

  /// Compatibility method - returns day theme (blue)
  static ThemeData get lightTheme => dayTheme;

  /// Dark theme configuration with blue backgrounds
  static ThemeData get darkTheme {
    const ColorScheme darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9FA8DA),
      onPrimary: Color(0xFF1A237E),
      primaryContainer: Color(0xFF283593), // Blue background
      onPrimaryContainer: Color(0xFFE8EAF6), // Light text
      secondary: Color(0xFF9FA8DA),
      onSecondary: Color(0xFF283593),
      secondaryContainer: Color(0xFF3F51B5), // Blue background
      onSecondaryContainer: Color(0xFFE1E5FF), // Light text
      tertiary: Color(0xFF7986CB),
      onTertiary: Color(0xFF1A237E),
      tertiaryContainer: Color(0xFF5C6BC0), // Blue background
      onTertiaryContainer: Color(0xFFE8EAF6), // Light text
      error: Color(0xFFEF5350),
      onError: Color(0xFFB71C1C),
      errorContainer: Color(0xFFD32F2F),
      onErrorContainer: Color(0xFFFFCDD2), // Light text
      surface: Color(0xFF1A237E), // Dark blue surface
      onSurface: Color(0xFFE8EAF6), // Light text
      surfaceContainerHighest: Color(0xFF283593), // Blue surface variant
      onSurfaceVariant: Color(0xFFB3B9F2), // Light grayish blue text
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF3F51B5),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFF9FA8DA),
    );

    return _buildTheme(darkColorScheme);
  }

  /// Common text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
}
