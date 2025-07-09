import 'package:flutter/foundation.dart';

/// Alarm model representing a scheduled alarm
/// 
/// This model contains all the information needed to schedule and display
/// an alarm, including time, recurrence, sound settings, and state.
@immutable
class Alarm {
  /// Unique identifier for the alarm
  final String id;
  
  /// User-friendly label for the alarm
  final String label;
  
  /// Time when the alarm should ring
  final DateTime time;
  
  /// Whether the alarm is currently enabled
  final bool isEnabled;
  
  /// Days of the week when alarm should repeat (0=Monday, 6=Sunday)
  final List<int> weekDays;
  
  /// Path to the sound file to play
  final String soundPath;
  
  /// Snooze duration in minutes
  final int snoozeMinutes;
  
  /// Whether to vibrate when alarm rings
  final bool vibrate;

  /// Creates a new alarm instance
  const Alarm({
    required this.id,
    required this.label,
    required this.time,
    this.isEnabled = true,
    this.weekDays = const [],
    this.soundPath = '',
    this.snoozeMinutes = 5,
    this.vibrate = true,
  });

  /// Converts alarm to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'time': time.toIso8601String(),
      'isEnabled': isEnabled,
      'weekDays': weekDays,
      'soundPath': soundPath,
      'snoozeMinutes': snoozeMinutes,
      'vibrate': vibrate,
    };
  }

  /// Creates alarm from JSON storage
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      label: json['label'] as String,
      time: DateTime.parse(json['time'] as String),
      isEnabled: json['isEnabled'] as bool? ?? true,
      weekDays: List<int>.from(json['weekDays'] as List? ?? []),
      soundPath: json['soundPath'] as String? ?? '',
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }

  // Copy with modifications
  Alarm copyWith({
    String? id,
    String? label,
    DateTime? time,
    bool? isEnabled,
    List<int>? weekDays,
    String? soundPath,
    int? snoozeMinutes,
    bool? vibrate,
  }) {
    return Alarm(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      weekDays: weekDays ?? this.weekDays,
      soundPath: soundPath ?? this.soundPath,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  // Check if alarm is recurring (has weekdays set)
  bool get isRecurring => weekDays.isNotEmpty;

  // Get formatted time string
  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Get weekdays as string
  String get weekDaysString {
    if (weekDays.isEmpty) return 'Once';
    
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekDays.length == 7) return 'Every day';
    if (weekDays.length == 5 && !weekDays.contains(5) && !weekDays.contains(6)) {
      return 'Weekdays';
    }
    if (weekDays.length == 2 && weekDays.contains(5) && weekDays.contains(6)) {
      return 'Weekends';
    }
    
    return weekDays.map((day) => days[day]).join(', ');
  }
}
