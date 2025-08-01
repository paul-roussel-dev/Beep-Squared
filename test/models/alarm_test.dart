import 'package:flutter_test/flutter_test.dart';
import 'package:beep_squared/models/alarm.dart';

void main() {
  group('Alarm Model Tests', () {
    group('Alarm Creation Tests', () {
      test('should create alarm with all properties', () {
        // Arrange & Act
        final alarm = Alarm(
          id: 'test-id-123',
          label: 'Morning Alarm',
          time: DateTime(2025, 8, 1, 7, 30, 0),
          isEnabled: true,
          weekDays: const [1, 2, 3, 4, 5], // Mon-Fri
          soundPath: 'morning-bell.mp3',
          snoozeMinutes: 10,
          vibrate: true,
        );

        // Assert
        expect(alarm.id, equals('test-id-123'));
        expect(alarm.label, equals('Morning Alarm'));
        expect(alarm.time, equals(DateTime(2025, 8, 1, 7, 30, 0)));
        expect(alarm.isEnabled, isTrue);
        expect(alarm.weekDays, equals([1, 2, 3, 4, 5]));
        expect(alarm.soundPath, equals('morning-bell.mp3'));
        expect(alarm.snoozeMinutes, equals(10));
        expect(alarm.vibrate, isTrue);
      });

      test('should create one-time alarm', () {
        // Arrange & Act
        final oneTimeAlarm = Alarm(
          id: 'onetime-1',
          label: 'Doctor Appointment',
          time: DateTime(2025, 8, 15, 14, 30, 0),
          isEnabled: true,
          weekDays: const [], // Empty = one-time
          soundPath: 'gentle-chime.mp3',
          snoozeMinutes: 5,
          vibrate: false,
        );

        // Assert
        expect(oneTimeAlarm.weekDays.isEmpty, isTrue);
        expect(oneTimeAlarm.isRecurring, isFalse);
      });

      test('should create recurring alarm', () {
        // Arrange & Act
        final recurringAlarm = Alarm(
          id: 'recurring-1',
          label: 'Daily Workout',
          time: DateTime(2025, 8, 1, 6, 0, 0),
          isEnabled: true,
          weekDays: const [0, 1, 2, 3, 4, 5, 6], // Every day
          soundPath: 'energetic-beep.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Assert
        expect(recurringAlarm.weekDays.isNotEmpty, isTrue);
        expect(recurringAlarm.isRecurring, isTrue);
        expect(recurringAlarm.weekDays.length, equals(7));
      });
    });

    group('Alarm Properties Tests', () {
      test('should identify recurring vs one-time alarms', () {
        // One-time alarm
        final oneTime = Alarm(
          id: '1',
          label: 'One Time',
          time: DateTime.now(),
          isEnabled: true,
          weekDays: const [],
          soundPath: 'sound.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Recurring alarm
        final recurring = Alarm(
          id: '2',
          label: 'Recurring',
          time: DateTime.now(),
          isEnabled: true,
          weekDays: const [1, 3, 5],
          soundPath: 'sound.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        expect(oneTime.isRecurring, isFalse);
        expect(recurring.isRecurring, isTrue);
      });

      test('should validate weekday values', () {
        // Valid weekdays (0-6)
        final validWeekdays = [0, 1, 2, 3, 4, 5, 6];

        final alarm = Alarm(
          id: 'weekday-test',
          label: 'Test Weekdays',
          time: DateTime.now(),
          isEnabled: true,
          weekDays: validWeekdays,
          soundPath: 'sound.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // All weekdays should be in valid range
        for (final day in alarm.weekDays) {
          expect(day, greaterThanOrEqualTo(0));
          expect(day, lessThanOrEqualTo(6));
        }
      });

      test('should handle different snooze durations', () {
        final testCases = [1, 5, 10, 15, 30, 60];

        for (final minutes in testCases) {
          final alarm = Alarm(
            id: 'snooze-$minutes',
            label: 'Snooze Test $minutes',
            time: DateTime.now(),
            isEnabled: true,
            weekDays: const [],
            soundPath: 'sound.mp3',
            snoozeMinutes: minutes,
            vibrate: true,
          );

          expect(alarm.snoozeMinutes, equals(minutes));
          expect(alarm.snoozeMinutes, greaterThan(0));
        }
      });
    });

    group('Alarm Copy and Update Tests', () {
      test('should copy alarm with updated properties', () {
        // Arrange
        final originalAlarm = Alarm(
          id: 'original',
          label: 'Original Label',
          time: DateTime(2025, 8, 1, 8, 0, 0),
          isEnabled: false,
          weekDays: const [1, 2, 3],
          soundPath: 'original.mp3',
          snoozeMinutes: 5,
          vibrate: false,
        );

        // Act
        final updatedAlarm = originalAlarm.copyWith(
          label: 'Updated Label',
          isEnabled: true,
          vibrate: true,
        );

        // Assert - Updated properties
        expect(updatedAlarm.label, equals('Updated Label'));
        expect(updatedAlarm.isEnabled, isTrue);
        expect(updatedAlarm.vibrate, isTrue);

        // Assert - Unchanged properties
        expect(updatedAlarm.id, equals(originalAlarm.id));
        expect(updatedAlarm.time, equals(originalAlarm.time));
        expect(updatedAlarm.weekDays, equals(originalAlarm.weekDays));
        expect(updatedAlarm.soundPath, equals(originalAlarm.soundPath));
        expect(updatedAlarm.snoozeMinutes, equals(originalAlarm.snoozeMinutes));
      });

      test('should copy alarm with new time', () {
        // Arrange
        final originalAlarm = Alarm(
          id: 'time-test',
          label: 'Time Test',
          time: DateTime(2025, 8, 1, 7, 0, 0),
          isEnabled: true,
          weekDays: const [1, 2, 3, 4, 5],
          soundPath: 'sound.mp3',
          snoozeMinutes: 10,
          vibrate: true,
        );

        final newTime = DateTime(2025, 8, 1, 8, 30, 0);

        // Act
        final updatedAlarm = originalAlarm.copyWith(time: newTime);

        // Assert
        expect(updatedAlarm.time, equals(newTime));
        expect(updatedAlarm.time, isNot(equals(originalAlarm.time)));

        // Other properties unchanged
        expect(updatedAlarm.id, equals(originalAlarm.id));
        expect(updatedAlarm.label, equals(originalAlarm.label));
      });
    });

    group('Alarm Serialization Tests', () {
      test('should convert alarm to and from JSON-like format', () {
        // Arrange
        final originalAlarm = Alarm(
          id: 'json-test',
          label: 'JSON Test Alarm',
          time: DateTime(2025, 8, 1, 12, 30, 0),
          isEnabled: true,
          weekDays: const [0, 6], // Weekend
          soundPath: 'weekend-chill.mp3',
          snoozeMinutes: 15,
          vibrate: false,
        );

        // Act - Simulate JSON serialization properties
        final alarmData = {
          'id': originalAlarm.id,
          'label': originalAlarm.label,
          'time': originalAlarm.time.millisecondsSinceEpoch,
          'isEnabled': originalAlarm.isEnabled,
          'weekDays': originalAlarm.weekDays,
          'soundPath': originalAlarm.soundPath,
          'snoozeMinutes': originalAlarm.snoozeMinutes,
          'vibrate': originalAlarm.vibrate,
        };

        // Simulate JSON deserialization
        final reconstructedAlarm = Alarm(
          id: alarmData['id'] as String,
          label: alarmData['label'] as String,
          time: DateTime.fromMillisecondsSinceEpoch(alarmData['time'] as int),
          isEnabled: alarmData['isEnabled'] as bool,
          weekDays: List<int>.from(alarmData['weekDays'] as List),
          soundPath: alarmData['soundPath'] as String,
          snoozeMinutes: alarmData['snoozeMinutes'] as int,
          vibrate: alarmData['vibrate'] as bool,
        );

        // Assert
        expect(reconstructedAlarm.id, equals(originalAlarm.id));
        expect(reconstructedAlarm.label, equals(originalAlarm.label));
        expect(reconstructedAlarm.time, equals(originalAlarm.time));
        expect(reconstructedAlarm.isEnabled, equals(originalAlarm.isEnabled));
        expect(reconstructedAlarm.weekDays, equals(originalAlarm.weekDays));
        expect(reconstructedAlarm.soundPath, equals(originalAlarm.soundPath));
        expect(
          reconstructedAlarm.snoozeMinutes,
          equals(originalAlarm.snoozeMinutes),
        );
        expect(reconstructedAlarm.vibrate, equals(originalAlarm.vibrate));
      });
    });

    group('Alarm Edge Cases Tests', () {
      test('should handle empty and null-like values', () {
        // Minimum valid alarm
        final minimalAlarm = Alarm(
          id: '',
          label: '',
          time: DateTime(1970, 1, 1), // Epoch
          isEnabled: false,
          weekDays: const [],
          soundPath: '',
          snoozeMinutes: 1, // Minimum positive value
          vibrate: false,
        );

        expect(minimalAlarm.id, isEmpty);
        expect(minimalAlarm.label, isEmpty);
        expect(minimalAlarm.weekDays, isEmpty);
        expect(minimalAlarm.soundPath, isEmpty);
        expect(minimalAlarm.snoozeMinutes, greaterThan(0));
      });

      test('should handle extreme time values', () {
        // Far future alarm
        final futureAlarm = Alarm(
          id: 'future',
          label: 'Future Alarm',
          time: DateTime(2030, 12, 31, 23, 59, 59),
          isEnabled: true,
          weekDays: const [],
          soundPath: 'future.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        expect(futureAlarm.time.year, equals(2030));
        expect(futureAlarm.time.isAfter(DateTime.now()), isTrue);
      });

      test('should handle duplicate weekdays', () {
        // Alarm with duplicate weekdays (should be handled by UI, but test model)
        final alarm = Alarm(
          id: 'duplicate-days',
          label: 'Duplicate Days Test',
          time: DateTime.now(),
          isEnabled: true,
          weekDays: const [1, 2, 2, 3, 3, 3], // Duplicates
          soundPath: 'sound.mp3',
          snoozeMinutes: 5,
          vibrate: true,
        );

        // Model stores what's given (UI should handle deduplication)
        expect(alarm.weekDays.length, equals(6));
        expect(alarm.weekDays.contains(2), isTrue);
        expect(alarm.weekDays.contains(3), isTrue);
      });
    });
  });
}
