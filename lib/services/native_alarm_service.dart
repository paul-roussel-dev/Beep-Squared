import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Service for handling native alarm scheduling on Android
/// 
/// This service uses Android's AlarmManager to schedule exact alarms
/// that can trigger even when the app is closed or the device is asleep.
class NativeAlarmService {
  static NativeAlarmService? _instance;
  static const MethodChannel _channel = MethodChannel('com.example.beep_squared/alarm');
  
  /// Private constructor to prevent direct instantiation
  NativeAlarmService._();
  
  /// Singleton instance accessor
  static NativeAlarmService get instance {
    _instance ??= NativeAlarmService._();
    return _instance!;
  }

  StreamController<String>? _alarmTriggerController;
  Stream<String>? _alarmTriggerStream;

  /// Initialize the native alarm service
  Future<void> initialize() async {
    // Set up method call handler for native -> Flutter communication
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Initialize alarm trigger stream
    _alarmTriggerController = StreamController<String>.broadcast();
    _alarmTriggerStream = _alarmTriggerController!.stream;
    
    debugPrint('Native alarm service initialized');
  }

  /// Handle method calls from native code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAlarmTriggered':
        final String alarmId = call.arguments as String;
        debugPrint('Alarm triggered from native: $alarmId');
        _alarmTriggerController?.add(alarmId);
        return null;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Schedule an alarm using Android's AlarmManager
  Future<void> scheduleAlarm({
    required String alarmId,
    required DateTime scheduledTime,
    required Map<String, dynamic> alarmData,
  }) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'alarmId': alarmId,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'alarmData': alarmData,
      });
      debugPrint('Native alarm scheduled: $alarmId at $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling native alarm: $e');
      rethrow;
    }
  }

  /// Cancel an alarm
  Future<void> cancelAlarm(String alarmId) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {'alarmId': alarmId});
      debugPrint('Native alarm cancelled: $alarmId');
    } catch (e) {
      debugPrint('Error cancelling native alarm: $e');
      rethrow;
    }
  }

  /// Cancel all alarms
  Future<void> cancelAllAlarms() async {
    try {
      await _channel.invokeMethod('cancelAllAlarms');
      debugPrint('All native alarms cancelled');
    } catch (e) {
      debugPrint('Error cancelling all native alarms: $e');
      rethrow;
    }
  }

  /// Get the stream of alarm triggers
  Stream<String> get alarmTriggerStream => _alarmTriggerStream!;

  /// Dispose resources
  void dispose() {
    _alarmTriggerController?.close();
    _alarmTriggerController = null;
    _alarmTriggerStream = null;
  }
}
