import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Manages manual theme overrides and automatic theme switching
class ThemeManager {
  ThemeManager._();
  static final ThemeManager _instance = ThemeManager._();
  static ThemeManager get instance => _instance;

  bool _manualOverride = false;
  bool _isEveningModeManual = false;

  // Cache for time settings to avoid repeated reads
  int? _cachedEveningStart;
  int? _cachedEveningEnd;

  /// Whether manual override is active
  bool get isManualOverride => _manualOverride;

  /// Current manual evening mode state
  bool get isEveningModeManual => _isEveningModeManual;

  /// Get the current theme considering manual override
  Future<ThemeData> getCurrentTheme() async {
    if (_manualOverride) {
      return _isEveningModeManual ? AppTheme.eveningTheme : AppTheme.dayTheme;
    } else {
      return AppTheme.getAdaptiveThemeFromSettings();
    }
  }

  /// Toggle between day and evening theme manually
  void toggleThemeMode() {
    _manualOverride = true;
    _isEveningModeManual = !_isEveningModeManual;
    _saveManualState();
  }

  /// Get the effective evening state (manual or automatic)
  Future<bool> get effectiveIsEveningTimeAsync async {
    if (_manualOverride) {
      return _isEveningModeManual;
    } else {
      // Use settings-based time calculation
      final prefs = await SharedPreferences.getInstance();
      final eveningStart =
          prefs.getInt('evening_start_hour') ?? AppTheme.eveningStartHour;
      final eveningEnd =
          prefs.getInt('evening_end_hour') ?? AppTheme.eveningEndHour;
      return AppTheme.isEveningTimeCustom(eveningStart, eveningEnd);
    }
  }

  /// Get the effective evening state (manual or automatic) - synchronous version
  /// Uses cached settings for immediate response
  bool get effectiveIsEveningTime {
    if (_manualOverride) {
      return _isEveningModeManual;
    } else {
      final eveningStart = _cachedEveningStart ?? AppTheme.eveningStartHour;
      final eveningEnd = _cachedEveningEnd ?? AppTheme.eveningEndHour;
      return AppTheme.isEveningTimeCustom(eveningStart, eveningEnd);
    }
  }

  /// Reset to automatic mode
  void resetToAutomatic() {
    _manualOverride = false;
    _isEveningModeManual = false;
    _saveManualState();
  }

  /// Initialize from saved preferences
  Future<void> initialize() async {
    await _loadManualState();
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

  /// Reload time settings cache
  Future<void> reloadTimeSettings() async {
    await _loadTimeSettings();
  }

  /// Save manual override state to preferences
  Future<void> _saveManualState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manual_theme_override', _manualOverride);
      await prefs.setBool('manual_evening_mode', _isEveningModeManual);
    } catch (e) {
      debugPrint('Error saving manual theme state: $e');
    }
  }

  /// Load manual override state from preferences
  Future<void> _loadManualState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _manualOverride = prefs.getBool('manual_theme_override') ?? false;
      _isEveningModeManual = prefs.getBool('manual_evening_mode') ?? false;
    } catch (e) {
      debugPrint('Error loading manual theme state: $e');
      _manualOverride = false;
      _isEveningModeManual = false;
    }
  }
}
