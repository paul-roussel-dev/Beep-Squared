import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/alarm.dart';
import 'alarm_service.dart';

/// Service for handling native Android alarms
/// 
/// This service uses Android's AlarmManager to schedule exact alarms
/// that can trigger even when the app is closed or the device is sleeping.
class AndroidAlarmService {
  static AndroidAlarmService? _instance;
  static const MethodChannel _channel = MethodChannel('beep_squared.alarm/native');
  
  /// Private constructor
  AndroidAlarmService._();
  
  /// Singleton instance
  static AndroidAlarmService get instance {
    _instance ??= AndroidAlarmService._();
    return _instance!;
  }

  bool _isInitialized = false;
  StreamController<String>? _alarmController;

  /// Initialize the Android alarm service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up method call handler for native -> Flutter communication
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Initialize alarm stream
    _alarmController = StreamController<String>.broadcast();
    
    _isInitialized = true;
    debugPrint('Android alarm service initialized');
  }

  /// Handle method calls from native Android code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('Received method call: ${call.method}');
    
    switch (call.method) {
      case 'onAlarmTriggered':
        final String alarmId = call.arguments as String;
        debugPrint('Alarm triggered from Android: $alarmId');
        
        // Trigger the alarm screen
        await _triggerAlarmScreen(alarmId);
        return null;
        
      case 'requestAlarmPermissions':
        // Handle permission requests if needed
        return true;
        
      default:
        throw PlatformException(
          code: 'Unimplemented',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Trigger alarm screen - ALWAYS use native approach for consistency
  Future<void> _triggerAlarmScreen(String alarmId) async {
    try {
      debugPrint('=== TRIGGERING NATIVE ALARM SCREEN FOR: $alarmId ===');
      
      // Get alarm details to pass ringtone info
      final alarmService = AlarmService.instance;
      final alarms = await alarmService.getAlarms();
      final alarm = alarms.firstWhere((a) => a.id == alarmId, orElse: () => Alarm(
        id: alarmId,
        time: DateTime.now(),
        label: 'Alarm',
        isEnabled: true,
        soundPath: 'default',
        vibrate: true,
        weekDays: const [],
      ));
      
      // ALWAYS use the native alarm display system with configured sound
      await _channel.invokeMethod('triggerNativeAlarm', {
        'alarmId': alarmId,
        'label': alarm.label,
        'ringtone': alarm.soundPath,
        'immediate': true,
      });
      
      // Also notify the stream for any Flutter listeners
      _alarmController?.add(alarmId);
      
      debugPrint('Native alarm screen triggered successfully with ringtone: ${alarm.soundPath}');
      
    } catch (e) {
      debugPrint('Error triggering native alarm screen: $e');
      // Fallback: still notify the stream
      _alarmController?.add(alarmId);
    }
  }

  /// Schedule an alarm using Android AlarmManager
  Future<void> scheduleAlarm(Alarm alarm, DateTime scheduledTime) async {
    if (!_isInitialized) await initialize();

    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'alarmId': alarm.id,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'label': alarm.label,
        'soundPath': alarm.soundPath,
        'vibrate': alarm.vibrate,
        'weekDays': alarm.weekDays,
      });
      
      debugPrint('Android alarm scheduled: ${alarm.id} at $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling Android alarm: $e');
      rethrow;
    }
  }

  /// Cancel an alarm
  Future<void> cancelAlarm(String alarmId) async {
    if (!_isInitialized) await initialize();

    try {
      await _channel.invokeMethod('cancelAlarm', {'alarmId': alarmId});
      debugPrint('Android alarm cancelled: $alarmId');
    } catch (e) {
      debugPrint('Error cancelling Android alarm: $e');
      rethrow;
    }
  }

  /// Cancel all alarms
  Future<void> cancelAllAlarms() async {
    if (!_isInitialized) await initialize();

    try {
      await _channel.invokeMethod('cancelAllAlarms');
      debugPrint('All Android alarms cancelled');
    } catch (e) {
      debugPrint('Error cancelling all Android alarms: $e');
      rethrow;
    }
  }

  /// Get alarm trigger stream
  Stream<String> get alarmStream => _alarmController!.stream;

  /// Dispose resources
  void dispose() {
    _alarmController?.close();
    _alarmController = null;
    _isInitialized = false;
  }
}
