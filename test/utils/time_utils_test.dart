import 'package:flutter_test/flutter_test.dart';
import 'package:beep_squared/utils/time_utils.dart';

void main() {
  group('Time Utils Tests', () {
    group('Time Formatting Tests', () {
      test('should format time correctly in 24-hour format', () {
        // Test various times
        expect(
          TimeUtils.formatTime24Hour(DateTime(2025, 8, 1, 7, 30)),
          equals('07:30'),
        );
        expect(
          TimeUtils.formatTime24Hour(DateTime(2025, 8, 1, 15, 45)),
          equals('15:45'),
        );
        expect(
          TimeUtils.formatTime24Hour(DateTime(2025, 8, 1, 0, 0)),
          equals('00:00'),
        );
        expect(
          TimeUtils.formatTime24Hour(DateTime(2025, 8, 1, 23, 59)),
          equals('23:59'),
        );
        expect(
          TimeUtils.formatTime24Hour(DateTime(2025, 8, 1, 12, 0)),
          equals('12:00'),
        );
      });

      test('should format time correctly in 12-hour format', () {
        // Morning times
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 7, 30)),
          equals('7:30 AM'),
        );
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 0, 0)),
          equals('12:00 AM'),
        );
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 11, 59)),
          equals('11:59 AM'),
        );

        // Afternoon/Evening times
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 15, 45)),
          equals('3:45 PM'),
        );
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 12, 0)),
          equals('12:00 PM'),
        );
        expect(
          TimeUtils.formatTime12Hour(DateTime(2025, 8, 1, 23, 59)),
          equals('11:59 PM'),
        );
      });

      test('should handle edge cases for time formatting', () {
        // Midnight
        final midnight = DateTime(2025, 8, 1, 0, 0);
        expect(TimeUtils.formatTime24Hour(midnight), equals('00:00'));
        expect(TimeUtils.formatTime12Hour(midnight), equals('12:00 AM'));

        // Noon
        final noon = DateTime(2025, 8, 1, 12, 0);
        expect(TimeUtils.formatTime24Hour(noon), equals('12:00'));
        expect(TimeUtils.formatTime12Hour(noon), equals('12:00 PM'));

        // Single digit minutes
        final singleDigit = DateTime(2025, 8, 1, 9, 5);
        expect(TimeUtils.formatTime24Hour(singleDigit), equals('09:05'));
        expect(TimeUtils.formatTime12Hour(singleDigit), equals('9:05 AM'));
      });
    });

    group('Weekday Formatting Tests', () {
      test('should format weekdays correctly', () {
        expect(TimeUtils.getWeekdayName(0), equals('Mon'));
        expect(TimeUtils.getWeekdayName(1), equals('Tue'));
        expect(TimeUtils.getWeekdayName(2), equals('Wed'));
        expect(TimeUtils.getWeekdayName(3), equals('Thu'));
        expect(TimeUtils.getWeekdayName(4), equals('Fri'));
        expect(TimeUtils.getWeekdayName(5), equals('Sat'));
        expect(TimeUtils.getWeekdayName(6), equals('Sun'));
      });

      test('should format full weekday names correctly', () {
        expect(TimeUtils.getFullWeekdayName(0), equals('Monday'));
        expect(TimeUtils.getFullWeekdayName(1), equals('Tuesday'));
        expect(TimeUtils.getFullWeekdayName(2), equals('Wednesday'));
        expect(TimeUtils.getFullWeekdayName(3), equals('Thursday'));
        expect(TimeUtils.getFullWeekdayName(4), equals('Friday'));
        expect(TimeUtils.getFullWeekdayName(5), equals('Saturday'));
        expect(TimeUtils.getFullWeekdayName(6), equals('Sunday'));
      });

      test('should handle invalid weekday indices gracefully', () {
        expect(TimeUtils.getWeekdayName(-1), equals(''));
        expect(TimeUtils.getWeekdayName(7), equals(''));
        expect(TimeUtils.getWeekdayName(100), equals(''));

        expect(TimeUtils.getFullWeekdayName(-1), equals(''));
        expect(TimeUtils.getFullWeekdayName(7), equals(''));
        expect(TimeUtils.getFullWeekdayName(100), equals(''));
      });
    });

    group('Weekday List Formatting Tests', () {
      test('should format weekday lists correctly', () {
        expect(TimeUtils.formatWeekdays([]), equals('One time'));
        expect(TimeUtils.formatWeekdays([0]), equals('Mon'));
        expect(TimeUtils.formatWeekdays([0, 1]), equals('Mon, Tue'));
        expect(TimeUtils.formatWeekdays([0, 1, 2, 3, 4]), equals('Mon-Fri'));
        expect(TimeUtils.formatWeekdays([5, 6]), equals('Sat, Sun'));
        expect(
          TimeUtils.formatWeekdays([0, 1, 2, 3, 4, 5, 6]),
          equals('Every day'),
        );
      });

      test('should handle special weekday patterns', () {
        // Weekdays
        expect(TimeUtils.formatWeekdays([0, 1, 2, 3, 4]), equals('Mon-Fri'));

        // Weekend
        expect(TimeUtils.formatWeekdays([5, 6]), equals('Sat, Sun'));

        // Every day
        expect(
          TimeUtils.formatWeekdays([0, 1, 2, 3, 4, 5, 6]),
          equals('Every day'),
        );

        // Custom patterns
        expect(TimeUtils.formatWeekdays([0, 2, 4]), equals('Mon, Wed, Fri'));
        expect(TimeUtils.formatWeekdays([1, 3, 5]), equals('Tue, Thu, Sat'));
      });

      test('should sort weekdays in correct order', () {
        // Unsorted input should be sorted in output
        expect(
          TimeUtils.formatWeekdays([6, 0, 3, 1]),
          equals('Mon, Tue, Thu, Sun'),
        );
        expect(
          TimeUtils.formatWeekdays([4, 2, 0, 6, 1]),
          equals('Mon, Tue, Wed, Fri, Sun'),
        );
      });
    });

    group('Time Duration Tests', () {
      test('should calculate time until alarm correctly', () {
        final now = DateTime(2025, 8, 1, 14, 30, 0);

        // Same day, future time
        final futureToday = DateTime(2025, 8, 1, 18, 0, 0);
        expect(TimeUtils.timeUntilAlarm(now, futureToday), equals('in 3h 30m'));

        // Tomorrow
        final tomorrow = DateTime(2025, 8, 2, 7, 0, 0);
        expect(TimeUtils.timeUntilAlarm(now, tomorrow), equals('in 16h 30m'));

        // Minutes only
        final soonToday = DateTime(2025, 8, 1, 14, 45, 0);
        expect(TimeUtils.timeUntilAlarm(now, soonToday), equals('in 15m'));

        // Hours only
        final hourLater = DateTime(2025, 8, 1, 16, 30, 0);
        expect(TimeUtils.timeUntilAlarm(now, hourLater), equals('in 2h'));
      });

      test('should handle past times for recurring alarms', () {
        final now = DateTime(
          2025,
          8,
          1,
          14,
          30,
          0,
        ); // Friday 14:30 (weekday index 4)

        // Past time today - should show next occurrence
        final pastToday = DateTime(2025, 8, 1, 10, 0, 0);
        expect(
          TimeUtils.timeUntilNextOccurrence(now, pastToday, [4]),
          equals('in 6 days'),
        ); // Next Friday (6 days later)

        // Past time with multiple weekdays - next Monday is 3 days away (Fri->Sat->Sun->Mon)
        expect(
          TimeUtils.timeUntilNextOccurrence(now, pastToday, [0, 2, 4]),
          equals('in 2 days'),
        ); // Next Monday (Aug 4th)
      });
    });

    group('Alarm Time Validation Tests', () {
      test('should validate alarm times correctly', () {
        final now = DateTime(2025, 8, 1, 14, 30, 0);

        // Future time - valid
        final futureTime = DateTime(2025, 8, 1, 15, 0, 0);
        expect(TimeUtils.isValidAlarmTime(futureTime, now), isTrue);

        // Past time, one-time alarm - invalid
        final pastTime = DateTime(2025, 8, 1, 13, 0, 0);
        expect(
          TimeUtils.isValidAlarmTime(pastTime, now, isRecurring: false),
          isFalse,
        );

        // Past time, recurring alarm - valid (will occur next week)
        expect(
          TimeUtils.isValidAlarmTime(pastTime, now, isRecurring: true),
          isTrue,
        );

        // Same time - should be valid with grace period
        final sameTime = DateTime(2025, 8, 1, 14, 30, 0);
        expect(TimeUtils.isValidAlarmTime(sameTime, now), isTrue);
      });

      test('should apply grace period for alarm validation', () {
        final now = DateTime(2025, 8, 1, 14, 30, 0);

        // 1 minute ago - within grace period
        final oneMinuteAgo = DateTime(2025, 8, 1, 14, 29, 0);
        expect(
          TimeUtils.isValidAlarmTime(oneMinuteAgo, now, gracePeriodMinutes: 2),
          isTrue,
        );

        // 3 minutes ago - outside grace period
        final threeMinutesAgo = DateTime(2025, 8, 1, 14, 27, 0);
        expect(
          TimeUtils.isValidAlarmTime(
            threeMinutesAgo,
            now,
            gracePeriodMinutes: 2,
          ),
          isFalse,
        );
      });
    });

    group('Time Comparison Tests', () {
      test('should compare times correctly', () {
        final time1 = DateTime(2025, 8, 1, 14, 30, 0);
        final time2 = DateTime(2025, 8, 1, 15, 30, 0);
        final time3 = DateTime(2025, 8, 1, 14, 30, 0);

        expect(TimeUtils.isTimeBefore(time1, time2), isTrue);
        expect(TimeUtils.isTimeBefore(time2, time1), isFalse);
        expect(TimeUtils.isTimeBefore(time1, time3), isFalse); // Same time

        expect(TimeUtils.isTimeAfter(time2, time1), isTrue);
        expect(TimeUtils.isTimeAfter(time1, time2), isFalse);
        expect(TimeUtils.isTimeAfter(time1, time3), isFalse); // Same time

        expect(TimeUtils.isSameTime(time1, time3), isTrue);
        expect(TimeUtils.isSameTime(time1, time2), isFalse);
      });

      test('should compare only time components, ignoring date', () {
        final today = DateTime(2025, 8, 1, 14, 30, 0);
        final tomorrow = DateTime(2025, 8, 2, 14, 30, 0);

        expect(TimeUtils.isSameTimeOfDay(today, tomorrow), isTrue);
        expect(TimeUtils.isSameTime(today, tomorrow), isFalse);
      });
    });

    group('Next Alarm Time Calculation Tests', () {
      test('should calculate next alarm time for recurring alarms', () {
        final now = DateTime(
          2025,
          8,
          1,
          14,
          30,
          0,
        ); // Friday 14:30 (weekday index 4)
        final alarmTime = DateTime(2025, 8, 1, 10, 0, 0); // 10:00 AM

        // Monday-Friday alarm, past time today
        final nextMondayFriday = TimeUtils.getNextAlarmTime(now, alarmTime, [
          0,
          1,
          2,
          3,
          4,
        ]);
        expect(nextMondayFriday.weekday, equals(1)); // Monday (3 days away)
        expect(nextMondayFriday.hour, equals(10));
        expect(nextMondayFriday.minute, equals(0));

        // Weekend alarm - Saturday is tomorrow from Friday
        final nextWeekend = TimeUtils.getNextAlarmTime(now, alarmTime, [5, 6]);
        expect(nextWeekend.weekday, equals(6)); // Saturday (tomorrow)
        expect(nextWeekend.hour, equals(10));
        expect(nextWeekend.minute, equals(0));
      });

      test('should handle same day alarm if time is in future', () {
        final now = DateTime(2025, 8, 1, 10, 0, 0); // Friday 10:00
        final alarmTime = DateTime(2025, 8, 1, 14, 30, 0); // 14:30 PM

        // Friday alarm, future time today
        final nextFriday = TimeUtils.getNextAlarmTime(now, alarmTime, [
          4,
        ]); // Friday = 4
        expect(nextFriday.day, equals(1)); // Same day
        expect(nextFriday.hour, equals(14));
        expect(nextFriday.minute, equals(30));
      });
    });
  });
}
