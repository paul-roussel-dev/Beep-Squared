import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Manages automatic theme switching based on time settings
class ThemeManager {
  ThemeManager._();
  static final ThemeManager _instance = ThemeManager._();
  static ThemeManager get instance => _instance;

  // Cache for time settings to avoid repeated reads
  int? _cachedEveningStart;
  int? _cachedEveningEnd;

  /// Get the current theme based on time settings
  Future<ThemeData> getCurrentTheme() async {
    // Use custom time settings for automatic mode
    await _loadTimeSettings(); // Ensure settings are fresh
    final isEvening = AppTheme.isEveningTimeCustom(
      _cachedEveningStart ?? AppTheme.eveningStartHour,
      _cachedEveningEnd ?? AppTheme.eveningEndHour,
    );
    return isEvening ? AppTheme.eveningTheme : AppTheme.dayTheme;
  }

  /// Get the effective evening state based on time settings
  bool get effectiveIsEveningTime {
    final eveningStart = _cachedEveningStart ?? AppTheme.eveningStartHour;
    final eveningEnd = _cachedEveningEnd ?? AppTheme.eveningEndHour;
    return AppTheme.isEveningTimeCustom(eveningStart, eveningEnd);
  }

  /// Initialize from saved preferences
  Future<void> initialize() async {
    await _loadTimeSettings();
  }

  /// Load custom time settings
  Future<void> _loadTimeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedEveningStart =
          prefs.getInt('evening_start_hour') ?? AppTheme.eveningStartHour;
      _cachedEveningEnd =
          prefs.getInt('evening_end_hour') ?? AppTheme.eveningEndHour;
    } catch (e) {
      debugPrint('Error loading time settings: $e');
      _cachedEveningStart = AppTheme.eveningStartHour;
      _cachedEveningEnd = AppTheme.eveningEndHour;
    }
  }

  /// Invalidate cached time settings (call when settings change)
  void invalidateTimeCache() {
    _cachedEveningStart = null;
    _cachedEveningEnd = null;
  }
}
