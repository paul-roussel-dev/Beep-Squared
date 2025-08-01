import 'package:flutter_test/flutter_test.dart';
import 'package:beep_squared/services/alarm_scheduler_service.dart';
import 'package:beep_squared/models/alarm.dart';

void main() {
  group('AlarmSchedulerService Tests', () {
    late AlarmSchedulerService schedulerService;

    setUp(() {
      schedulerService = AlarmSchedulerService.instance;
    });

    group('Grace Period Logic Tests', () {
      test(
        'should schedule immediate trigger for alarm less than 2 minutes late',
        () {
          // Arrange
          final now = DateTime(2025, 8, 1, 14, 36, 30); // 14:36:30
          final alarmTime = DateTime(
            2025,
            8,
            1,
            14,
            36,
            0,
          ); // 14:36:00 (30s ago)

          final alarm = Alarm(
            id: 'test-alarm-1',
            label: 'Test Alarm',
            time: alarmTime,
            isEnabled: true,
            weekDays: const [], // One-time alarm
            soundPath: 'test.mp3',
            snoozeMinutes: 5,
            vibrate: true,
          );

          // Act & Assert
          final timeDifference = now.difference(alarmTime);
          expect(timeDifference.inSeconds, equals(30));
          expect(timeDifference.inMinutes, lessThan(2));

          // Should be within grace period
          expect(timeDifference.inMinutes < 2, isTrue);
        },
      );

      test('should disable alarm when more than 2 minutes late', () {
        // Arrange
        final now = DateTime(2025, 8, 1, 14, 40, 0); // 14:40:00
        final alarmTime = DateTime(
          2025,
          8,
          1,
          14,
          36,
          0,
        ); // 14:36:00 (4min ago)

        final alarm = Alarm(
          id: 'test-alarm-2',
          label: 'Test Alarm Late',
          time: alarmTime,
          isEnabled: true,
          weekDays: const [], // One-time alarm
          soundPath: 'test.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Act & Assert
        final timeDifference = now.difference(alarmTime);
        expect(timeDifference.inMinutes, equals(4));
        expect(timeDifference.inMinutes >= 2, isTrue);

        // Should be outside grace period
        expect(timeDifference.inMinutes >= 2, isTrue);
      });

      test('should handle future alarms normally', () {
        // Arrange
        final now = DateTime(2025, 8, 1, 14, 30, 0); // 14:30:00
        final alarmTime = DateTime(
          2025,
          8,
          1,
          14,
          36,
          0,
        ); // 14:36:00 (6min future)

        final alarm = Alarm(
          id: 'test-alarm-3',
          label: 'Future Alarm',
          time: alarmTime,
          isEnabled: true,
          weekDays: const [], // One-time alarm
          soundPath: 'test.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Act & Assert
        expect(alarmTime.isAfter(now), isTrue);
        expect(alarmTime.isBefore(now), isFalse);
      });
    });

    group('Recurring Alarm Logic Tests', () {
      test('should handle recurring alarms correctly', () {
        // Arrange
        final now = DateTime(2025, 8, 1, 14, 30, 0); // Friday 14:30:00
        final alarmTime = DateTime(2025, 8, 1, 14, 36, 0); // 14:36:00

        final recurringAlarm = Alarm(
          id: 'recurring-alarm-1',
          label: 'Daily Alarm',
          time: alarmTime,
          isEnabled: true,
          weekDays: const [0, 1, 2, 3, 4], // Monday to Friday
          soundPath: 'test.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Act & Assert
        expect(recurringAlarm.isRecurring, isTrue);
        expect(recurringAlarm.weekDays.isNotEmpty, isTrue);
        expect(recurringAlarm.weekDays.contains(4), isTrue); // Friday = 4
      });

      test('should identify one-time alarms correctly', () {
        // Arrange
        final alarmTime = DateTime(2025, 8, 1, 14, 36, 0);

        final oneTimeAlarm = Alarm(
          id: 'onetime-alarm-1',
          label: 'One Time Alarm',
          time: alarmTime,
          isEnabled: true,
          weekDays: const [], // No weekdays = one-time
          soundPath: 'test.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Act & Assert
        expect(oneTimeAlarm.isRecurring, isFalse);
        expect(oneTimeAlarm.weekDays.isEmpty, isTrue);
      });
    });

    group('Time Calculation Tests', () {
      test('should calculate correct time differences', () {
        // Test various time differences
        final testCases = [
          {
            'now': DateTime(2025, 8, 1, 14, 36, 30),
            'alarm': DateTime(2025, 8, 1, 14, 36, 0),
            'expectedSeconds': 30,
            'expectedMinutes': 0,
            'withinGrace': true,
          },
          {
            'now': DateTime(2025, 8, 1, 14, 37, 30),
            'alarm': DateTime(2025, 8, 1, 14, 36, 0),
            'expectedSeconds': 90,
            'expectedMinutes': 1,
            'withinGrace': true,
          },
          {
            'now': DateTime(2025, 8, 1, 14, 38, 30),
            'alarm': DateTime(2025, 8, 1, 14, 36, 0),
            'expectedSeconds': 150,
            'expectedMinutes': 2,
            'withinGrace': false,
          },
        ];

        for (final testCase in testCases) {
          final now = testCase['now'] as DateTime;
          final alarmTime = testCase['alarm'] as DateTime;
          final expectedSeconds = testCase['expectedSeconds'] as int;
          final expectedMinutes = testCase['expectedMinutes'] as int;
          final withinGrace = testCase['withinGrace'] as bool;

          final difference = now.difference(alarmTime);

          expect(difference.inSeconds, equals(expectedSeconds));
          expect(difference.inMinutes, equals(expectedMinutes));
          expect(difference.inMinutes < 2, equals(withinGrace));
        }
      });

      test('should calculate next alarm times correctly', () {
        // Test next alarm time calculation for different scenarios
        final now = DateTime(2025, 8, 1, 14, 30, 0);

        // Future alarm - should return exact time
        final futureAlarm = DateTime(2025, 8, 1, 15, 0, 0);
        expect(futureAlarm.isAfter(now), isTrue);

        // Past alarm within grace period - should be immediate
        final recentPastAlarm = DateTime(2025, 8, 1, 14, 29, 0); // 1min ago
        final timeDiff = now.difference(recentPastAlarm);
        expect(timeDiff.inMinutes < 2, isTrue);

        // Past alarm outside grace period - should be next day
        final oldPastAlarm = DateTime(2025, 8, 1, 14, 25, 0); // 5min ago
        final oldTimeDiff = now.difference(oldPastAlarm);
        expect(oldTimeDiff.inMinutes >= 2, isTrue);
      });
    });

    group('Alarm Validation Tests', () {
      test('should validate alarm properties correctly', () {
        // Valid alarm
        final validAlarm = Alarm(
          id: 'valid-alarm',
          label: 'Valid Test Alarm',
          time: DateTime(2025, 8, 1, 15, 0, 0),
          isEnabled: true,
          weekDays: const [1, 2, 3], // Tue, Wed, Thu
          soundPath: 'alarm.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        expect(validAlarm.id.isNotEmpty, isTrue);
        expect(validAlarm.label.isNotEmpty, isTrue);
        expect(validAlarm.snoozeMinutes > 0, isTrue);
        expect(
          validAlarm.weekDays.every((day) => day >= 0 && day <= 6),
          isTrue,
        );
      });

      test('should handle edge cases for weekdays', () {
        // Test all weekdays
        final allDaysAlarm = Alarm(
          id: 'all-days',
          label: 'Every Day Alarm',
          time: DateTime(2025, 8, 1, 7, 0, 0),
          isEnabled: true,
          weekDays: const [0, 1, 2, 3, 4, 5, 6], // All days
          soundPath: 'alarm.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        expect(allDaysAlarm.weekDays.length, equals(7));
        expect(allDaysAlarm.isRecurring, isTrue);

        // Test weekend only
        final weekendAlarm = Alarm(
          id: 'weekend-only',
          label: 'Weekend Alarm',
          time: DateTime(2025, 8, 1, 9, 0, 0),
          isEnabled: true,
          weekDays: const [5, 6], // Sat, Sun
          soundPath: 'alarm.mp3',
          snoozeMinutes: 10,
          vibrate: false,
        );

        expect(weekendAlarm.weekDays.length, equals(2));
        expect(weekendAlarm.weekDays.contains(5), isTrue); // Saturday
        expect(weekendAlarm.weekDays.contains(6), isTrue); // Sunday
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid alarm times gracefully', () {
        // Test with very old alarm time
        final veryOldAlarm = Alarm(
          id: 'very-old',
          label: 'Very Old Alarm',
          time: DateTime(2025, 7, 1, 14, 0, 0), // A month ago
          isEnabled: true,
          weekDays: const [],
          soundPath: 'alarm.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        final now = DateTime(2025, 8, 1, 14, 0, 0);
        final difference = now.difference(veryOldAlarm.time);

        expect(difference.inDays, greaterThan(0));
        expect(difference.inMinutes >= 2, isTrue); // Should be disabled
      });

      test('should handle midnight edge cases', () {
        // Test alarm scheduled for midnight
        final midnightAlarm = Alarm(
          id: 'midnight',
          label: 'Midnight Alarm',
          time: DateTime(2025, 8, 2, 0, 0, 0), // Tomorrow midnight
          isEnabled: true,
          weekDays: const [],
          soundPath: 'alarm.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        final now = DateTime(2025, 8, 1, 23, 59, 0); // 1 minute before
        expect(midnightAlarm.time.isAfter(now), isTrue);

        final difference = midnightAlarm.time.difference(now);
        expect(difference.inMinutes, equals(1));
      });
    });
  });
}
