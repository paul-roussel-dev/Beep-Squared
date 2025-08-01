import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import '../models/alarm.dart';
import 'alarm_service.dart';
import 'alarm_manager_service.dart';
import 'android_alarm_service.dart';

/// Service for scheduling and managing alarm notifications
///
/// This service handles scheduling alarms using the system's notification
/// system and manages alarm triggers when they go off.
class AlarmSchedulerService {
  static AlarmSchedulerService? _instance;

  /// Private constructor to prevent direct instantiation
  AlarmSchedulerService._();

  /// Singleton instance accessor
  static AlarmSchedulerService get instance {
    _instance ??= AlarmSchedulerService._();
    return _instance!;
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Create the alarm notification channel
    await _createAlarmChannel();

    _isInitialized = true;
  }

  /// Create alarm notification channel
  Future<void> _createAlarmChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap/response
  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = json.decode(response.payload!);
      final String alarmId = data['alarmId'] as String;

      // Trigger alarm screen
      _triggerAlarmScreen(alarmId);
    }
  }

  /// Handle background notification response (when notification fires automatically)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = json.decode(response.payload!);
      final String alarmId = data['alarmId'] as String;

      // Trigger alarm screen from background
      AlarmManagerService.instance
          .triggerAlarmFromBackground(alarmId)
          .catchError((error) {
            debugPrint('Error triggering alarm from background: $error');
          });
    }
  }

  /// Handle when a scheduled notification is displayed (automatic trigger)
  @pragma('vm:entry-point')
  static void _onNotificationDisplayed(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = json.decode(response.payload!);
      final String alarmId = data['alarmId'] as String;

      // Automatically trigger alarm screen when notification is displayed
      AlarmManagerService.instance
          .triggerAlarmFromBackground(alarmId)
          .catchError((error) {
            debugPrint('Error triggering alarm on display: $error');
          });
    }
  }

  /// Trigger the alarm screen
  void _triggerAlarmScreen(String alarmId) {
    // Trigger alarm through the manager service
    AlarmManagerService.instance.triggerAlarm(alarmId).catchError((error) {
      debugPrint('Error triggering alarm: $error');
    });
  }

  /// Schedule an alarm notification
  Future<void> scheduleAlarm(Alarm alarm) async {
    if (!_isInitialized) await initialize();

    final int notificationId = alarm.id.hashCode;
    final now = DateTime.now();

    // For one-time alarms, check if time has significantly passed (more than 2 minutes)
    // This allows users to activate alarms even if they're a few seconds late
    if (alarm.weekDays.isEmpty && alarm.time.isBefore(now)) {
      final timeDifference = now.difference(alarm.time);

      if (timeDifference.inMinutes >= 2) {
        // Only disable if significantly in the past (2+ minutes)
        debugPrint(
          'Skipping one-time alarm significantly in the past: ${alarm.time} vs $now (${timeDifference.inMinutes}min ago)',
        );
        final alarmService = AlarmService.instance;
        final updatedAlarm = alarm.copyWith(isEnabled: false);
        await alarmService.updateAlarm(updatedAlarm);
        debugPrint('One-time alarm disabled: ${alarm.id}');
        return;
      } else {
        // If less than 2 minutes, schedule for immediate trigger (grace period)
        debugPrint(
          'Alarm is ${timeDifference.inSeconds}s late - scheduling immediate trigger with 5s grace period',
        );
        final immediateTime = now.add(const Duration(seconds: 5));

        // Use Android native alarm for immediate trigger
        try {
          await AndroidAlarmService.instance.scheduleAlarm(
            alarm,
            immediateTime,
          );
          debugPrint(
            'Native Android alarm scheduled with grace period: ${alarm.id} at $immediateTime',
          );
          return;
        } catch (e) {
          debugPrint('Error scheduling immediate Android alarm: $e');
          // Continue with notification fallback
        }
      }
    }

    // Calculate next alarm time
    final DateTime nextAlarmTime = _getNextAlarmTime(alarm);

    // Use Android native alarm for better reliability
    try {
      await AndroidAlarmService.instance.scheduleAlarm(alarm, nextAlarmTime);
      debugPrint(
        'Native Android alarm scheduled: ${alarm.id} at $nextAlarmTime',
      );
      return;
    } catch (e) {
      debugPrint('Error scheduling Android alarm: $e');
      debugPrint(
        'Failed to schedule native alarm, falling back to notification: $e',
      );
      // Continue with notification fallback only if native completely fails
    }

    // Fallback to notification-based alarm
    // Create notification details with immediate trigger
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          showWhen: true,
          when: nextAlarmTime.millisecondsSinceEpoch,
          // Use default notification sound
          playSound: true,
          enableVibration: alarm.vibrate,
          ongoing: true,
          autoCancel: false,
          // Critical notification that shows immediately
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          onlyAlertOnce: false,
          // Add wake lock and screen on
          actions: [
            const AndroidNotificationAction(
              'dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze',
              cancelNotification: false,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      notificationId,
      'Alarm: ${alarm.label}',
      'Time to wake up!',
      _convertToTZDateTime(nextAlarmTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'alarmId': alarm.id,
        'alarmLabel': alarm.label,
        'soundPath': alarm.soundPath,
        'vibrate': alarm.vibrate,
        'triggerTime': nextAlarmTime.millisecondsSinceEpoch,
      }),
    );

    debugPrint('Alarm scheduled for: $nextAlarmTime');
  }

  /// Schedule a snooze alarm (immediate scheduling)
  Future<void> scheduleSnoozeAlarm(Alarm alarm, DateTime snoozeTime) async {
    if (!_isInitialized) await initialize();

    final int notificationId = alarm.id.hashCode;

    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          showWhen: true,
          when: snoozeTime.millisecondsSinceEpoch,
          // Use default notification sound
          playSound: true,
          enableVibration: alarm.vibrate,
          ongoing: true,
          autoCancel: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification for the exact snooze time
    await _notifications.zonedSchedule(
      notificationId,
      'Alarm: ${alarm.label}',
      'Time to wake up!',
      _convertToTZDateTime(snoozeTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'alarmId': alarm.id,
        'alarmLabel': alarm.label,
        'soundPath': alarm.soundPath,
        'vibrate': alarm.vibrate,
      }),
    );

    debugPrint('Snooze alarm scheduled for: $snoozeTime');
  }

  /// Cancel an alarm notification
  Future<void> cancelAlarm(String alarmId) async {
    try {
      final int notificationId = alarmId.hashCode;
      await _notifications.cancel(notificationId);
      debugPrint('Alarm cancelled: $alarmId');
    } catch (e) {
      debugPrint('Error cancelling alarm $alarmId: $e');
      // In release builds, some Flutter Local Notifications operations may fail
      // due to obfuscation. We continue execution but log the error.
      if (kReleaseMode) {
        debugPrint('Release mode: Ignoring flutter_local_notifications error');
      } else {
        rethrow;
      }
    }
  }

  /// Cancel all alarms
  Future<void> cancelAllAlarms() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All alarms cancelled');
    } catch (e) {
      debugPrint('Error cancelling all alarms: $e');
      // In release builds, some Flutter Local Notifications operations may fail
      // due to obfuscation. We continue execution but log the error.
      if (kReleaseMode) {
        debugPrint(
          'Release mode: Ignoring flutter_local_notifications error for cancelAll',
        );
        // Alternative: Cancel alarms individually if we have a list
        try {
          final alarms = await AlarmService.instance.getAlarms();
          for (final alarm in alarms) {
            try {
              final int notificationId = alarm.id.hashCode;
              await _notifications.cancel(notificationId);
            } catch (individualError) {
              debugPrint(
                'Error cancelling individual alarm ${alarm.id}: $individualError',
              );
            }
          }
        } catch (fallbackError) {
          debugPrint('Fallback cancel method also failed: $fallbackError');
        }
      } else {
        rethrow;
      }
    }
  }

  /// Get next alarm time based on alarm configuration
  DateTime _getNextAlarmTime(Alarm alarm) {
    final now = DateTime.now();

    // For one-time alarms (no weekdays specified), use the exact time
    if (alarm.weekDays.isEmpty) {
      // If it's a one-time alarm and the time has passed, check tolerance
      if (alarm.time.isBefore(now)) {
        final timeDifference = now.difference(alarm.time);

        if (timeDifference.inMinutes < 2) {
          // Within grace period - schedule for immediate trigger
          debugPrint(
            'One-time alarm within grace period: ${timeDifference.inSeconds}s late - scheduling immediate trigger',
          );
          return now.add(const Duration(seconds: 5));
        } else {
          // Significantly past - schedule for tomorrow
          debugPrint(
            'Warning: One-time alarm time has significantly passed: ${alarm.time} vs $now (${timeDifference.inMinutes}min)',
          );
          return DateTime(
            now.year,
            now.month,
            now.day + 1,
            alarm.time.hour,
            alarm.time.minute,
          );
        }
      }
      return alarm.time;
    }

    // For recurring alarms, find next occurrence
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // If alarm is for today but time has passed, schedule for tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    // If alarm has specific weekdays, find next occurrence
    while (!alarm.weekDays.contains(alarmTime.weekday - 1)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    return alarmTime;
  }

  /// Convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Reschedule all active alarms
  Future<void> rescheduleAllAlarms() async {
    // First, clean up expired one-time alarms
    await AlarmService.instance.cleanupExpiredAlarms();

    final alarms = await AlarmService.instance.getAlarms();

    // Cancel all existing notifications
    await cancelAllAlarms();

    // Reschedule active alarms
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    // For now, return true - permissions will be handled by the system
    // In a real implementation, you'd use the appropriate permission package
    return true;
  }

  /// Force trigger an alarm immediately (for testing or snooze)
  Future<void> triggerAlarmNow(String alarmId) async {
    if (!_isInitialized) await initialize();

    final int notificationId = alarmId.hashCode;

    // Create immediate notification
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
          playSound: true,
          enableVibration: true,
          ongoing: true,
          autoCancel: false,
          visibility: NotificationVisibility.public,
          channelShowBadge: true,
          onlyAlertOnce: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show immediate notification
    await _notifications.show(
      notificationId,
      'Alarm Triggered',
      'Wake up! Alarm is ringing',
      details,
      payload: json.encode({
        'alarmId': alarmId,
        'alarmLabel': 'Immediate Alarm',
        'soundPath': 'alarm-clock-short-6402.mp3',
        'vibrate': true,
      }),
    );

    // Also trigger the alarm screen directly
    _triggerAlarmScreen(alarmId);
  }

  /// Force reinitialize the notification service (useful for release build issues)
  Future<void> forceReinitialize() async {
    _isInitialized = false;
    debugPrint('Force reinitializing notification service...');

    try {
      await initialize();
      debugPrint('Notification service reinitialized successfully');
    } catch (e) {
      debugPrint('Error during force reinitialization: $e');
      // Even if it fails, mark as initialized to prevent infinite loops
      _isInitialized = true;
      if (kReleaseMode) {
        debugPrint('Release mode: Continuing despite reinitialization failure');
      } else {
        rethrow;
      }
    }
  }

  /// Check if notification service is healthy (for release build diagnostics)
  Future<bool> isServiceHealthy() async {
    try {
      // Try a simple operation to test if the service works
      await _notifications.getNotificationAppLaunchDetails();
      return true;
    } catch (e) {
      debugPrint('Notification service health check failed: $e');
      return false;
    }
  }
}
