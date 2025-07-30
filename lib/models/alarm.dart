import 'package:flutter/foundation.dart';

/// Unlock method for dismissing an alarm
enum AlarmUnlockMethod {
  /// Simple tap to dismiss
  simple('Simple', 'Tap to dismiss'),

  /// Solve math problem
  math('Math', 'Solve math problem');

  const AlarmUnlockMethod(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Math difficulty settings
enum MathDifficulty {
  easy('Facile', 'Calculs simples (1-50)'),
  medium('Moyen', 'Calculs moyens (1-100)'),
  hard('Difficile', 'Calculs difficiles (1-200)');

  const MathDifficulty(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Math operations settings
enum MathOperations {
  additionOnly('Addition', '+'),
  subtractionOnly('Soustraction', '-'),
  multiplicationOnly('Multiplication', '×'),
  mixed('Mélangé', '+ - ×');

  const MathOperations(this.displayName, this.symbol);
  final String displayName;
  final String symbol;
}

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

  /// Method required to unlock/dismiss the alarm
  final AlarmUnlockMethod unlockMethod;

  /// Math difficulty for math unlock method
  final MathDifficulty mathDifficulty;

  /// Math operations for math unlock method
  final MathOperations mathOperations;

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
    this.unlockMethod = AlarmUnlockMethod.simple,
    this.mathDifficulty = MathDifficulty.easy,
    this.mathOperations = MathOperations.mixed,
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
      'unlockMethod': unlockMethod.name,
      'mathDifficulty': mathDifficulty.name,
      'mathOperations': mathOperations.name,
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
      unlockMethod: AlarmUnlockMethod.values.firstWhere(
        (method) => method.name == (json['unlockMethod'] as String?),
        orElse: () => AlarmUnlockMethod.simple,
      ),
      mathDifficulty: MathDifficulty.values.firstWhere(
        (difficulty) => difficulty.name == (json['mathDifficulty'] as String?),
        orElse: () => MathDifficulty.easy,
      ),
      mathOperations: MathOperations.values.firstWhere(
        (operations) => operations.name == (json['mathOperations'] as String?),
        orElse: () => MathOperations.mixed,
      ),
    );
  }

  /// Copy with modifications
  Alarm copyWith({
    String? id,
    String? label,
    DateTime? time,
    bool? isEnabled,
    List<int>? weekDays,
    String? soundPath,
    int? snoozeMinutes,
    bool? vibrate,
    AlarmUnlockMethod? unlockMethod,
    MathDifficulty? mathDifficulty,
    MathOperations? mathOperations,
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
      unlockMethod: unlockMethod ?? this.unlockMethod,
      mathDifficulty: mathDifficulty ?? this.mathDifficulty,
      mathOperations: mathOperations ?? this.mathOperations,
    );
  }

  /// Check if alarm is recurring (has weekdays set)
  bool get isRecurring => weekDays.isNotEmpty;

  /// Get formatted time string
  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get weekdays as string
  String get weekDaysString {
    if (weekDays.isEmpty) return 'Once';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekDays.length == 7) return 'Every day';
    if (weekDays.length == 5 &&
        !weekDays.contains(5) &&
        !weekDays.contains(6)) {
      return 'Weekdays';
    }
    if (weekDays.length == 2 && weekDays.contains(5) && weekDays.contains(6)) {
      return 'Weekends';
    }

    return weekDays.map((day) => days[day]).join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alarm &&
        other.id == id &&
        other.label == label &&
        other.time == time &&
        other.isEnabled == isEnabled &&
        listEquals(other.weekDays, weekDays) &&
        other.soundPath == soundPath &&
        other.snoozeMinutes == snoozeMinutes &&
        other.vibrate == vibrate &&
        other.unlockMethod == unlockMethod;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      label,
      time,
      isEnabled,
      Object.hashAll(weekDays),
      soundPath,
      snoozeMinutes,
      vibrate,
      unlockMethod,
    );
  }

  @override
  String toString() {
    return 'Alarm{id: $id, label: $label, time: $time, isEnabled: $isEnabled, '
        'weekDays: $weekDays, soundPath: $soundPath, snoozeMinutes: $snoozeMinutes, '
        'vibrate: $vibrate, unlockMethod: $unlockMethod}';
  }
}
