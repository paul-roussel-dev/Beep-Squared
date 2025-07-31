import 'package:flutter/material.dart';

/// Application theme configuration following Material Design 3
///
/// This class provides a centralized theme configuration for the entire app,
/// ensuring consistency across all screens and components.
class AppTheme {
  AppTheme._();

  /// Light theme configuration with blue backgrounds and light text
  static ThemeData get lightTheme {
    const ColorScheme lightColorScheme = ColorScheme(
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
      outline: Color(0xFF79747E), // White text
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

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: lightColorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: lightColorScheme.onSurface),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: lightColorScheme.shadow.withValues(alpha: 0.1),
        surfaceTintColor: lightColorScheme.surfaceTint,
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
          side: BorderSide(color: lightColorScheme.outline, width: 1.5),
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
        fillColor: lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.onSurfaceVariant,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(
              0xFF1565C0,
            ); // Bleu foncé pour ON - contraste sur track blanc
          }
          return const Color(
            0xFFFFFFFF,
          ); // Blanc pour OFF - contraste sur track gris
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(
              0xFFE3F2FD,
            ); // Bleu très clair pour ON - contraste avec thumb bleu foncé
          }
          return const Color(
            0xFFBDBDBD,
          ); // Gris clair pour OFF - contraste avec thumb blanc
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            if (states.contains(WidgetState.selected)) {
              return const Color(
                0xFF1565C0,
              ).withValues(alpha: 0.1); // Bleu transparent
            }
            return const Color(0xFF757575).withValues(alpha: 0.1); // Gris transparent
          }
          return null;
        }),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: lightColorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant,
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

    return lightTheme.copyWith(
      colorScheme: darkColorScheme,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: darkColorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: darkColorScheme.onSurface),
      ),
      cardTheme: lightTheme.cardTheme.copyWith(
        surfaceTintColor: darkColorScheme.surfaceTint,
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: darkColorScheme.surfaceContainerHighest,
        hintStyle: TextStyle(
          color: darkColorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: darkColorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1),
        ),
      ),
      dialogTheme: lightTheme.dialogTheme.copyWith(
        titleTextStyle: TextStyle(
          color: darkColorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: darkColorScheme.onSurfaceVariant,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const Color(
              0xFF1565C0,
            ); // Bleu foncé quand activé - contraste sur track clair
          }
          return const Color(
            0xFFE0E0E0,
          ); // Gris très clair quand désactivé - contraste sur track sombre
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const Color(
              0xFFE3F2FD,
            ); // Bleu très clair quand activé - contraste avec thumb bleu foncé
          }
          return const Color(
            0xFF616161,
          ); // Gris moyen quand désactivé - contraste avec thumb clair
        }),
      ),
    );
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
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
