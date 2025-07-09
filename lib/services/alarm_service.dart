import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmService {
  static const String _alarmsKey = 'alarms';
  static AlarmService? _instance;
  
  AlarmService._();
  
  static AlarmService get instance {
    _instance ??= AlarmService._();
    return _instance!;
  }

  // Get all alarms
  Future<List<Alarm>> getAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(_alarmsKey);
      
      if (alarmsJson == null) return [];
      
      final List<dynamic> alarmsList = json.decode(alarmsJson);
      return alarmsList.map((alarmJson) => Alarm.fromJson(alarmJson)).toList();
    } catch (e) {
      print('Error loading alarms: $e');
      return [];
    }
  }

  // Save all alarms
  Future<bool> saveAlarms(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String alarmsJson = json.encode(
        alarms.map((alarm) => alarm.toJson()).toList(),
      );
      return await prefs.setString(_alarmsKey, alarmsJson);
    } catch (e) {
      print('Error saving alarms: $e');
      return false;
    }
  }

  // Add new alarm
  Future<bool> addAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    alarms.add(alarm);
    return await saveAlarms(alarms);
  }

  // Update alarm
  Future<bool> updateAlarm(Alarm updatedAlarm) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    
    if (index != -1) {
      alarms[index] = updatedAlarm;
      return await saveAlarms(alarms);
    }
    
    return false;
  }

  // Delete alarm
  Future<bool> deleteAlarm(String alarmId) async {
    final alarms = await getAlarms();
    alarms.removeWhere((alarm) => alarm.id == alarmId);
    return await saveAlarms(alarms);
  }

  // Toggle alarm enabled/disabled
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

  // Clear all alarms
  Future<bool> clearAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_alarmsKey);
    } catch (e) {
      print('Error clearing alarms: $e');
      return false;
    }
  }
}
