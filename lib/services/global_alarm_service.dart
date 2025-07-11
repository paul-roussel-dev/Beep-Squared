import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../screens/alarm_screen.dart';

/// Global alarm display service
/// 
/// This service manages the display of alarm screens when alarms are triggered
/// from native Android code. It maintains a reference to the current context
/// to ensure alarm screens can be displayed even when the app is in background.
class GlobalAlarmService {
  static GlobalAlarmService? _instance;
  static GlobalAlarmService get instance {
    _instance ??= GlobalAlarmService._();
    return _instance!;
  }
  
  GlobalAlarmService._();
  
  BuildContext? _currentContext;
  
  /// Set the current context for alarm display
  void setContext(BuildContext context) {
    _currentContext = context;
  }
  
  /// Clear the current context
  void clearContext() {
    _currentContext = null;
  }
  
  /// Show alarm screen
  Future<void> showAlarmScreen(Alarm alarm) async {
    if (_currentContext == null) {
      debugPrint('No context available for global alarm screen');
      return;
    }
    
    debugPrint('Showing global alarm screen for: ${alarm.label}');
    
    try {
      await showDialog(
        context: _currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent back button dismiss
            child: AlarmScreen(
              alarm: alarm,
              onDismiss: () {
                Navigator.of(context).pop();
                _dismissAlarm(alarm);
              },
              onSnooze: () {
                Navigator.of(context).pop();
                _snoozeAlarm(alarm);
              },
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing global alarm screen: $e');
    }
  }
  
  /// Handle alarm dismiss
  void _dismissAlarm(Alarm alarm) {
    debugPrint('Global alarm dismissed: ${alarm.label}');
    // Additional dismiss logic if needed
  }
  
  /// Handle alarm snooze
  void _snoozeAlarm(Alarm alarm) {
    debugPrint('Global alarm snoozed: ${alarm.label}');
    // Additional snooze logic if needed
    // Note: Snooze scheduling should be handled by the calling service
  }
}
