import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../services/alarm_manager_service.dart';

/// Service for monitoring and triggering alarms
/// 
/// This service runs in the background and checks for alarms that should
/// be triggered, providing a fallback mechanism for notifications.
class AlarmMonitorService {
  static AlarmMonitorService? _instance;
  
  /// Private constructor to prevent direct instantiation
  AlarmMonitorService._();
  
  /// Singleton instance accessor
  static AlarmMonitorService get instance {
    _instance ??= AlarmMonitorService._();
    return _instance!;
  }

  Timer? _monitorTimer;
  bool _isMonitoring = false;
  final Set<String> _triggeredAlarms = {};

  /// Start monitoring alarms
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    // Reduce polling frequency to every 30 seconds to minimize main thread impact
    _monitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Run check in background thread to avoid blocking UI
      Future.microtask(() => _checkAlarms());
    });
    
    debugPrint('Alarm monitoring started (30s interval)');
  }

  /// Stop monitoring alarms
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    _triggeredAlarms.clear();
    
    debugPrint('Alarm monitoring stopped');
  }

  /// Check if any alarms should be triggered (optimized for performance)
  Future<void> _checkAlarms() async {
    try {
      final alarms = await AlarmService.instance.getAlarms();
      final now = DateTime.now();
      
      // Only check enabled alarms to reduce processing
      final enabledAlarms = alarms.where((alarm) => alarm.isEnabled).toList();
      
      for (final alarm in enabledAlarms) {
        // Check if alarm should trigger
        if (_shouldTriggerAlarm(alarm, now)) {
          final alarmKey = _getAlarmKey(alarm, now);
          
          // Prevent duplicate triggers - once triggered, blocked for the day/time
          if (_triggeredAlarms.contains(alarmKey)) continue;
          
          // Mark as triggered IMMEDIATELY to prevent loops
          _triggeredAlarms.add(alarmKey);
          
          debugPrint('Triggering alarm: ${alarm.label} at ${now.toString()}');
          
          // For non-recurring alarms, disable them BEFORE triggering to prevent loops
          if (alarm.weekDays.isEmpty) {
            await _disableAlarm(alarm);
            debugPrint('Disabled one-time alarm: ${alarm.label}');
          }
          
          // Trigger the alarm immediately (non-blocking)
          AlarmManagerService.instance.triggerAlarm(alarm.id).catchError((error) {
            debugPrint('Error triggering alarm: $error');
          });
        }
      }
      
      // Clean up old triggered alarms periodically (less frequently)
      if (now.minute % 5 == 0) {
        _cleanupTriggeredAlarms(now);
      }
    } catch (e) {
      debugPrint('Error checking alarms: $e');
    }
  }

  /// Check if an alarm should be triggered (optimized)
  bool _shouldTriggerAlarm(Alarm alarm, DateTime now) {
    // For one-time alarms (weekDays empty), use the full DateTime comparison
    if (alarm.weekDays.isEmpty) {
      final timeDifference = now.difference(alarm.time);
      
      // Only log occasionally to reduce spam
      if (timeDifference.inSeconds >= -10 && timeDifference.inSeconds <= 30) {
        debugPrint('One-time alarm check: ${alarm.label}');
        debugPrint('  Difference: ${timeDifference.inSeconds} seconds');
      }
      
      // Trigger only if we're AFTER the alarm time and within 30 seconds
      return timeDifference.inSeconds >= 0 && timeDifference.inSeconds <= 30;
    }
    
    // For recurring alarms, check time of day and weekday
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );
    
    final timeDifference = now.difference(alarmTime);
    
    // Only log when close to trigger time to reduce spam
    if (timeDifference.inSeconds >= -10 && timeDifference.inSeconds <= 30) {
      debugPrint('Recurring alarm check: ${alarm.label}');
      debugPrint('  Difference: ${timeDifference.inSeconds} seconds');
    }
    
    // Check time window first
    if (timeDifference.inSeconds < 0 || timeDifference.inSeconds > 30) {
      return false;
    }
    
    // Check if it's the right day (if weekdays are specified)
    final currentWeekday = now.weekday - 1; // Convert to 0-6 format
    if (!alarm.weekDays.contains(currentWeekday)) {
      debugPrint('  Wrong day: current=$currentWeekday, needed=${alarm.weekDays}');
      return false;
    }
    
    return true;
  }

  /// Get a unique key for this alarm trigger
  String _getAlarmKey(Alarm alarm, DateTime now) {
    if (alarm.weekDays.isEmpty) {
      // Pour les alarmes ponctuelles, utiliser seulement l'ID + date (une fois par jour max)
      return '${alarm.id}_${now.year}_${now.month}_${now.day}';
    } else {
      // Pour les alarmes récurrentes, utiliser la date + heure du jour (une fois par jour pour cette heure)
      return '${alarm.id}_${now.year}_${now.month}_${now.day}_${alarm.time.hour}_${alarm.time.minute}';
    }
  }

  /// Disable an alarm after it's triggered (for one-time alarms)
  Future<void> _disableAlarm(Alarm alarm) async {
    try {
      final updatedAlarm = alarm.copyWith(isEnabled: false);
      await AlarmService.instance.updateAlarm(updatedAlarm);
      debugPrint('Disabled one-time alarm: ${alarm.label}');
    } catch (e) {
      debugPrint('Error disabling alarm: $e');
    }
  }

  /// Clean up old triggered alarms to prevent memory leaks
  void _cleanupTriggeredAlarms(DateTime now) {
    // Remove alarms that are more than 1 hour old
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    _triggeredAlarms.removeWhere((key) {
      try {
        final parts = key.split('_');
        if (parts.length >= 4) {
          // Extract date from key: alarmId_year_month_day[_hour_minute]
          final year = int.parse(parts[1]);
          final month = int.parse(parts[2]);
          final day = int.parse(parts[3]);
          
          final keyDate = DateTime(year, month, day);
          return keyDate.isBefore(oneHourAgo);
        }
        return true; // Remove malformed keys
      } catch (e) {
        return true; // Remove malformed keys
      }
    });
    
    // Log cleanup if we removed items
    if (_triggeredAlarms.length < 10) {
      debugPrint('Triggered alarms cleanup: ${_triggeredAlarms.length} items remaining');
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Mark an alarm as triggered to prevent duplicate triggers
  void markAlarmTriggered(String alarmKey) {
    _triggeredAlarms.add(alarmKey);
    debugPrint('Marked alarm as triggered: $alarmKey');
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
