class Alarm {
  final String id;
  final String label;
  final DateTime time;
  final bool isEnabled;
  final List<int> weekDays; // 0=Monday, 6=Sunday
  final String soundPath;
  final int snoozeMinutes;
  final bool vibrate;

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

  // Convert to JSON for storage
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

  // Create from JSON
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      label: json['label'],
      time: DateTime.parse(json['time']),
      isEnabled: json['isEnabled'] ?? true,
      weekDays: List<int>.from(json['weekDays'] ?? []),
      soundPath: json['soundPath'] ?? '',
      snoozeMinutes: json['snoozeMinutes'] ?? 5,
      vibrate: json['vibrate'] ?? true,
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
