import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../utils/constants.dart';

/// Service for managing alarms with persistent storage
/// 
/// This service handles CRUD operations for alarms and provides
/// a centralized way to manage alarm data across the application.
class AlarmService {
  static AlarmService? _instance;
  
  /// Private constructor to prevent direct instantiation
  AlarmService._();
  
  /// Singleton instance accessor
  static AlarmService get instance {
    _instance ??= AlarmService._();
    return _instance!;
  }

  /// Get all alarms from persistent storage
  Future<List<Alarm>> getAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(AppConstants.alarmsStorageKey);
      
      if (alarmsJson == null) return [];
      
      final List<dynamic> alarmsList = json.decode(alarmsJson);
      return alarmsList.map((alarmJson) => Alarm.fromJson(alarmJson)).toList();
    } catch (e) {
      debugPrint('Error loading alarms: $e');
      return [];
    }
  }

  /// Save all alarms to persistent storage
  Future<bool> saveAlarms(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String alarmsJson = json.encode(
        alarms.map((alarm) => alarm.toJson()).toList(),
      );
      return await prefs.setString(AppConstants.alarmsStorageKey, alarmsJson);
    } catch (e) {
      debugPrint('Error saving alarms: $e');
      return false;
    }
  }

  /// Add new alarm
  Future<bool> addAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    alarms.add(alarm);
    return await saveAlarms(alarms);
  }

  /// Update existing alarm
  Future<bool> updateAlarm(Alarm updatedAlarm) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    
    if (index != -1) {
      alarms[index] = updatedAlarm;
      return await saveAlarms(alarms);
    }
    
    return false;
  }

  /// Delete alarm by ID
  Future<bool> deleteAlarm(String alarmId) async {
    final alarms = await getAlarms();
    alarms.removeWhere((alarm) => alarm.id == alarmId);
    return await saveAlarms(alarms);
  }

  /// Toggle alarm enabled/disabled state
  Future<bool> toggleAlarm(String alarmId) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((alarm) => alarm.id == alarmId);
    
    if (index != -1) {
      alarms[index] = alarms[index].copyWith(
        isEnabled: !alarms[index].isEnabled,
      );
      return await saveAlarms(alarms);
    }
    
    return false;
  }

  /// Clear all alarms from storage
  Future<bool> clearAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(AppConstants.alarmsStorageKey);
    } catch (e) {
      debugPrint('Error clearing alarms: $e');
      return false;
    }
  }
}
