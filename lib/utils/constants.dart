import 'package:flutter/material.dart';

// App constants
class AppConstants {
  static const String appName = 'Beep Squared';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Modern Alarm Clock';
  
  // Colors
  static const primaryColor = Colors.indigo;
  static const accentColor = Colors.amber;
  
  // Alarm related strings
  static const String noAlarmsMessage = 'No alarms set';
  static const String addAlarmTooltip = 'Add alarm';
  static const String alarmSetMessage = 'Alarm set for';
  static const String alarmDeletedMessage = 'Alarm deleted';
  
  // Default values
  static const String defaultAlarmLabel = 'Alarm';
  static const int defaultSnoozeMinutes = 5;
}
