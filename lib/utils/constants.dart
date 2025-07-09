import 'package:flutter/material.dart';

/// Application constants following naming conventions
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // App information
  static const String appName = 'Beep Squared';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Modern Alarm Clock';
  
  // Colors following Material Design 3
  static const Color primaryColor = Colors.indigo;
  static const Color accentColor = Colors.amber;
  
  // Spacing constants (multiples of 8dp)
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // UI constants
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Alarm related strings
  static const String noAlarmsMessage = 'No alarms set';
  static const String addAlarmTooltip = 'Add alarm';
  static const String alarmSetMessage = 'Alarm set for';
  static const String alarmDeletedMessage = 'Alarm deleted';
  
  // Default values
  static const String defaultAlarmLabel = 'Alarm';
  static const int defaultSnoozeMinutes = 5;
  static const String defaultRingtonePath = 'assets/sounds/default_alarm.wav';
  
  // Audio constants
  static const int previewDurationSeconds = 3;
  static const double defaultVolume = 0.7;
  
  // Storage keys
  static const String alarmsStorageKey = 'alarms';
  static const String customRingtonesKey = 'custom_ringtones';
  static const String settingsKey = 'settings';
}
