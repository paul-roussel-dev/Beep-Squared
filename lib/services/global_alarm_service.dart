import 'package:flutter/material.dart';
import '../models/alarm.dart';

/// Global alarm display service - UNIFIED NATIVE VERSION
/// 
/// This service now delegates to the native unified alarm system
/// to ensure consistent alarm experience in-app and when backgrounded.
class GlobalAlarmService {
  static GlobalAlarmService? _instance;
  static GlobalAlarmService get instance {
    _instance ??= GlobalAlarmService._();
    return _instance!;
  }
  
  GlobalAlarmService._();
  
  /// Set the current context (still maintained for compatibility)
  void setContext(BuildContext context) {
    debugPrint('GlobalAlarmService: Context set (compatibility mode - native system used)');
  }
  
  /// Clear the current context
  void clearContext() {
    debugPrint('GlobalAlarmService: Context cleared (compatibility mode)');
  }
  
  /// Show alarm screen - DISABLED in favor of native unified system
  Future<void> showAlarmScreen(Alarm alarm) async {
    debugPrint('=== FLUTTER ALARM SCREEN DISABLED ===');
    debugPrint('Using native unified alarm system instead for: ${alarm.label}');
    debugPrint('The native system provides consistent experience in-app and background');
    
    // The native system will handle the alarm display
    // This ensures the same alarm experience everywhere
    return;
  }
  
  /// Show snooze notification - DISABLED
  Future<void> showSnoozeNotification(Alarm alarm, DateTime snoozeTime) async {
    debugPrint('Snooze notification disabled - native system handles this');
    return;
  }
  
  /// Dismiss alarm - DISABLED
  void dismissAlarm(String alarmId) {
    debugPrint('Alarm dismiss delegated to native system: $alarmId');
  }
}
