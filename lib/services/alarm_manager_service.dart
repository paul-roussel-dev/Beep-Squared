import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../screens/alarm_screen.dart';
import '../services/alarm_service.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/alarm_monitor_service.dart';

/// Service for managing active alarms and showing alarm screen
///
/// This service handles the display of the alarm screen when an alarm
/// is triggered and manages alarm dismissal and snoozing.
class AlarmManagerService {
  static AlarmManagerService? _instance;

  /// Private constructor to prevent direct instantiation
  AlarmManagerService._();

  /// Singleton instance accessor
  static AlarmManagerService get instance {
    _instance ??= AlarmManagerService._();
    return _instance!;
  }

  BuildContext? _context;
  bool _isAlarmActive = false;

  /// Set the main context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Show alarm screen when alarm is triggered
  Future<void> showAlarmScreen(Alarm alarm) async {
    if (_context == null) {
      debugPrint('No context available for alarm screen');
      return;
    }

    if (_isAlarmActive) {
      debugPrint(
        'Alarm already active, ignoring new trigger for: ${alarm.label}',
      );
      return;
    }

    _isAlarmActive = true;

    debugPrint('Showing alarm screen for: ${alarm.label}');

    try {
      // Show alarm screen as fullscreen dialog
      await showDialog(
        context: _context!,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => PopScope(
          canPop: false, // Prevent back button
          child: AlarmScreen(
            alarm: alarm,
            onDismiss: () => _dismissAlarm(alarm),
            onSnooze: () => _snoozeAlarm(alarm),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing alarm screen: $e');
    } finally {
      _isAlarmActive = false;
    }
  }

  /// Dismiss the alarm
  void _dismissAlarm(Alarm alarm) {
    if (_context == null) return;

    _isAlarmActive = false;
    Navigator.of(_context!).pop();

    // For recurring alarms, mark as triggered today to prevent repeat
    if (alarm.isRecurring) {
      _markAlarmTriggeredToday(alarm);
    } else {
      // For non-recurring alarms, disable them
      _disableAlarm(alarm);
    }
  }

  /// Mark alarm as triggered today to prevent repeat
  void _markAlarmTriggeredToday(Alarm alarm) {
    final now = DateTime.now();
    final alarmKey =
        '${alarm.id}_${now.year}_${now.month}_${now.day}_${alarm.time.hour}_${alarm.time.minute}';

    // Add to monitor service's triggered alarms to prevent repeat today
    AlarmMonitorService.instance.markAlarmTriggered(alarmKey);
  }

  /// Snooze the alarm
  void _snoozeAlarm(Alarm alarm) {
    if (_context == null) return;

    _isAlarmActive = false;
    Navigator.of(_context!).pop();

    // Schedule snooze alarm
    _scheduleSnoozeAlarm(alarm);
  }

  /// Disable a non-recurring alarm
  Future<void> _disableAlarm(Alarm alarm) async {
    final updatedAlarm = alarm.copyWith(isEnabled: false);
    await AlarmService.instance.updateAlarm(updatedAlarm);
  }

  /// Schedule a snooze alarm
  Future<void> _scheduleSnoozeAlarm(Alarm alarm) async {
    final snoozeTime = DateTime.now().add(
      Duration(minutes: alarm.snoozeMinutes),
    );

    // Create a temporary snooze alarm - don't save to storage
    final snoozeAlarm = alarm.copyWith(
      id: '${alarm.id}_snooze_${DateTime.now().millisecondsSinceEpoch}',
      label: '${alarm.label} (Snoozed)',
      time: snoozeTime, // Use the actual snooze time
      weekDays: [], // Snooze is one-time only
    );

    // Schedule it directly without saving to storage
    await AlarmSchedulerService.instance.scheduleSnoozeAlarm(
      snoozeAlarm,
      snoozeTime,
    );
  }

  /// Check if an alarm is currently active
  bool get isAlarmActive => _isAlarmActive;

  /// Trigger alarm by ID (called from notification system)
  Future<void> triggerAlarm(String alarmId) async {
    final alarms = await AlarmService.instance.getAlarms();
    final alarm = alarms.firstWhere(
      (a) => a.id == alarmId,
      orElse: () => throw Exception('Alarm not found: $alarmId'),
    );

    if (alarm.isEnabled) {
      await showAlarmScreen(alarm);
    }
  }

  /// Trigger alarm from background notification
  Future<void> triggerAlarmFromBackground(String alarmId) async {
    // Load alarm from storage
    final alarms = await AlarmService.instance.getAlarms();
    final alarm = alarms.firstWhere(
      (a) => a.id == alarmId,
      orElse: () => Alarm(
        id: alarmId,
        label: 'Background Alarm',
        time: DateTime.now(),
        isEnabled: true,
        weekDays: const [],
        soundPath: 'alarm-clock-short-6402.mp3',
        snoozeMinutes: 5,
        vibrate: true,
      ),
    );

    // If we have a context, show the alarm screen
    if (_context != null) {
      await showAlarmScreen(alarm);
    } else {
      // If no context, trigger a notification that will open the app
      await AlarmSchedulerService.instance.triggerAlarmNow(alarmId);
    }
  }

  /// Initialize the alarm manager
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await AlarmSchedulerService.instance.requestPermissions();

      // Reschedule all alarms on app start
      await AlarmSchedulerService.instance.rescheduleAllAlarms();
      debugPrint('Alarm manager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing alarm manager: $e');
      // In release builds, some operations may fail due to obfuscation
      // but we don't want to crash the app
      if (kReleaseMode) {
        debugPrint('Release mode: Continuing despite initialization errors');
      } else {
        rethrow;
      }
    }
  }
}
