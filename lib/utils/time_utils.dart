/// Utility class for time formatting and calculations
class TimeUtils {
  // Private constructor to prevent instantiation
  TimeUtils._();

  /// Format time in 24-hour format (HH:mm)
  static String formatTime24Hour(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format time in 12-hour format (h:mm AM/PM)
  static String formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get short weekday name (Mon, Tue, etc.)
  /// Index: 0=Monday, 1=Tuesday, ..., 6=Sunday
  static String getWeekdayName(int weekdayIndex) {
    if (weekdayIndex < 0 || weekdayIndex > 6) return '';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekdayIndex];
  }

  /// Get full weekday name (Monday, Tuesday, etc.)
  /// Index: 0=Monday, 1=Tuesday, ..., 6=Sunday
  static String getFullWeekdayName(int weekdayIndex) {
    if (weekdayIndex < 0 || weekdayIndex > 6) return '';

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekdayIndex];
  }

  /// Format a list of weekday indices into a readable string
  /// Returns patterns like "Mon-Fri", "Every day", "Sat, Sun", etc.
  static String formatWeekdays(List<int> weekdays) {
    if (weekdays.isEmpty) return 'One time';

    // Sort weekdays
    final sortedWeekdays = List<int>.from(weekdays)..sort();

    // Check for all days
    if (sortedWeekdays.length == 7) return 'Every day';

    // Check for weekdays (Mon-Fri)
    if (sortedWeekdays.length == 5 &&
        sortedWeekdays.every((day) => day >= 0 && day <= 4)) {
      return 'Mon-Fri';
    }

    // Check for weekend
    if (sortedWeekdays.length == 2 &&
        sortedWeekdays[0] == 5 &&
        sortedWeekdays[1] == 6) {
      return 'Sat, Sun';
    }

    // Default: list individual days
    return sortedWeekdays.map((day) => getWeekdayName(day)).join(', ');
  }

  /// Calculate time until alarm in readable format
  static String timeUntilAlarm(DateTime now, DateTime alarmTime) {
    final difference = alarmTime.difference(now);

    if (difference.isNegative) {
      return 'Alarm passed';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours == 0) {
      return 'in ${minutes}m';
    } else if (minutes == 0) {
      return 'in ${hours}h';
    } else {
      return 'in ${hours}h ${minutes}m';
    }
  }

  /// Calculate time until next occurrence of a recurring alarm
  static String timeUntilNextOccurrence(
    DateTime now,
    DateTime alarmTime,
    List<int> weekdays,
  ) {
    if (weekdays.isEmpty) {
      return timeUntilAlarm(now, alarmTime);
    }

    final nextAlarm = getNextAlarmTime(now, alarmTime, weekdays);
    final difference = nextAlarm.difference(now);
    final days = difference.inDays;

    if (days == 0) {
      return timeUntilAlarm(now, nextAlarm);
    } else if (days == 1) {
      return 'tomorrow';
    } else {
      return 'in $days days';
    }
  }

  /// Validate if an alarm time is valid (not in the past for one-time alarms)
  static bool isValidAlarmTime(
    DateTime alarmTime,
    DateTime now, {
    bool isRecurring = false,
    int gracePeriodMinutes = 2,
  }) {
    if (isRecurring) {
      return true; // Recurring alarms are always valid
    }

    // For one-time alarms, check if time is in future or within grace period
    final gracePeriod = Duration(minutes: gracePeriodMinutes);
    final earliestValidTime = now.subtract(gracePeriod);

    return alarmTime.isAfter(earliestValidTime);
  }

  /// Check if first time is before second time
  static bool isTimeBefore(DateTime time1, DateTime time2) {
    return time1.isBefore(time2);
  }

  /// Check if first time is after second time
  static bool isTimeAfter(DateTime time1, DateTime time2) {
    return time1.isAfter(time2);
  }

  /// Check if two times are exactly the same
  static bool isSameTime(DateTime time1, DateTime time2) {
    return time1.isAtSameMomentAs(time2);
  }

  /// Check if two times have the same hour and minute (ignoring date)
  static bool isSameTimeOfDay(DateTime time1, DateTime time2) {
    return time1.hour == time2.hour && time1.minute == time2.minute;
  }

  /// Calculate the next alarm time for a recurring alarm
  static DateTime getNextAlarmTime(
    DateTime now,
    DateTime alarmTime,
    List<int> weekdays,
  ) {
    if (weekdays.isEmpty) {
      // One-time alarm
      return alarmTime;
    }

    final nowWeekday = (now.weekday - 1) % 7; // Convert to 0-6 (Mon-Sun)
    final alarmHour = alarmTime.hour;
    final alarmMinute = alarmTime.minute;

    // Check if alarm can be today
    if (weekdays.contains(nowWeekday)) {
      final todayAlarm = DateTime(
        now.year,
        now.month,
        now.day,
        alarmHour,
        alarmMinute,
      );
      if (todayAlarm.isAfter(now)) {
        return todayAlarm;
      }
    }

    // Find next valid weekday
    for (int i = 1; i <= 7; i++) {
      final targetWeekday = (nowWeekday + i) % 7;
      if (weekdays.contains(targetWeekday)) {
        final targetDate = now.add(Duration(days: i));
        return DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          alarmHour,
          alarmMinute,
        );
      }
    }

    // Fallback (should never reach here if weekdays is not empty)
    return alarmTime;
  }
}
