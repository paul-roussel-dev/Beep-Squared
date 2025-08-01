import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:beep_squared/utils/constants.dart';

void main() {
  group('Constants Tests', () {
    group('App Information Tests', () {
      test('should have valid app name', () {
        expect(AppConstants.appName, isNotEmpty);
        expect(AppConstants.appName, equals('Beep Squared'));
      });

      test('should have valid app version', () {
        expect(AppConstants.appVersion, isNotEmpty);
        expect(AppConstants.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
        expect(AppConstants.appVersion, equals('1.0.0'));
      });
    });

    group('Spacing Constants Tests', () {
      test('should have consistent spacing values', () {
        expect(AppConstants.spacingSmall, lessThan(AppConstants.spacingMedium));
        expect(AppConstants.spacingMedium, lessThan(AppConstants.spacingLarge));

        // Check actual values
        expect(AppConstants.spacingSmall, equals(8.0));
        expect(AppConstants.spacingMedium, equals(16.0));
        expect(AppConstants.spacingLarge, equals(24.0));
      });

      test('should have positive spacing values', () {
        expect(AppConstants.spacingSmall, greaterThan(0));
        expect(AppConstants.spacingMedium, greaterThan(0));
        expect(AppConstants.spacingLarge, greaterThan(0));
      });

      test('should follow 8dp grid system', () {
        expect(AppConstants.spacingSmall % 8, equals(0));
        expect(AppConstants.spacingMedium % 8, equals(0));
        expect(AppConstants.spacingLarge % 8, equals(0));
      });
    });

    group('Icon Size Constants Tests', () {
      test('should have consistent icon size progression', () {
        expect(
          AppConstants.iconSizeSmall,
          lessThan(AppConstants.iconSizeMedium),
        );
        expect(
          AppConstants.iconSizeMedium,
          lessThan(AppConstants.iconSizeLarge),
        );

        // Check actual values
        expect(AppConstants.iconSizeSmall, equals(16.0));
        expect(AppConstants.iconSizeMedium, equals(24.0));
        expect(AppConstants.iconSizeLarge, equals(32.0));
      });

      test('should have positive icon sizes', () {
        expect(AppConstants.iconSizeSmall, greaterThan(0));
        expect(AppConstants.iconSizeMedium, greaterThan(0));
        expect(AppConstants.iconSizeLarge, greaterThan(0));
      });
    });

    group('Color Constants Tests', () {
      test('should have valid primary color', () {
        expect(AppConstants.primaryColor, equals(Colors.indigo));
        expect(AppConstants.primaryColor, isA<Color>());
      });
    });

    group('Default Alarm Settings Tests', () {
      test('should have valid default snooze minutes', () {
        expect(AppConstants.defaultSnoozeMinutes, greaterThan(0));
        expect(AppConstants.defaultSnoozeMinutes, equals(5));
        expect(
          AppConstants.defaultSnoozeMinutes,
          lessThanOrEqualTo(60),
        ); // Reasonable limit
      });

      test('should have valid default alarm label', () {
        expect(AppConstants.defaultAlarmLabel, isNotEmpty);
        expect(AppConstants.defaultAlarmLabel, equals('Alarm'));
      });

      test('should have valid default ringtone path', () {
        expect(AppConstants.defaultRingtonePath, isNotEmpty);
        expect(AppConstants.defaultRingtonePath, startsWith('assets/'));
        expect(AppConstants.defaultRingtonePath, endsWith('.wav'));
      });
    });

    group('Audio Constants Tests', () {
      test('should have reasonable preview duration', () {
        expect(AppConstants.previewDurationSeconds, greaterThan(0));
        expect(AppConstants.previewDurationSeconds, equals(3));
        expect(
          AppConstants.previewDurationSeconds,
          lessThanOrEqualTo(10),
        ); // Not too long
      });
    });

    group('Storage Keys Tests', () {
      test('should have valid storage keys', () {
        expect(AppConstants.alarmsStorageKey, isNotEmpty);
        expect(AppConstants.customRingtonesKey, isNotEmpty);
        expect(AppConstants.settingsKey, isNotEmpty);

        expect(AppConstants.alarmsStorageKey, equals('alarms'));
        expect(AppConstants.customRingtonesKey, equals('custom_ringtones'));
        expect(AppConstants.settingsKey, equals('settings'));
      });

      test('storage keys should be unique', () {
        final keys = [
          AppConstants.alarmsStorageKey,
          AppConstants.customRingtonesKey,
          AppConstants.settingsKey,
        ];

        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, equals(keys.length)); // No duplicates
      });

      test('storage keys should be lowercase with underscores', () {
        final keys = [
          AppConstants.alarmsStorageKey,
          AppConstants.customRingtonesKey,
          AppConstants.settingsKey,
        ];

        for (final key in keys) {
          expect(key, matches(RegExp(r'^[a-z_]+$')));
          expect(key.contains(' '), isFalse);
        }
      });
    });

    group('UI Message Constants Tests', () {
      test('should have valid UI messages', () {
        expect(AppConstants.noAlarmsMessage, isNotEmpty);
        expect(AppConstants.addAlarmTooltip, isNotEmpty);
        expect(AppConstants.alarmSetMessage, isNotEmpty);
        expect(AppConstants.alarmUpdatedMessage, isNotEmpty);
        expect(AppConstants.alarmDeletedMessage, isNotEmpty);

        // Check actual values
        expect(AppConstants.noAlarmsMessage, equals('No alarms set'));
        expect(AppConstants.addAlarmTooltip, equals('Add alarm'));
        expect(AppConstants.alarmSetMessage, equals('Alarm set for'));
        expect(AppConstants.alarmUpdatedMessage, equals('Alarm updated for'));
        expect(AppConstants.alarmDeletedMessage, equals('Alarm deleted'));
      });

      test('UI messages should be user-friendly', () {
        final messages = [
          AppConstants.noAlarmsMessage,
          AppConstants.addAlarmTooltip,
          AppConstants.alarmSetMessage,
          AppConstants.alarmUpdatedMessage,
          AppConstants.alarmDeletedMessage,
        ];

        for (final message in messages) {
          expect(message.length, greaterThan(3)); // Not too short
          expect(message.length, lessThan(50)); // Not too long
          expect(
            message[0].toUpperCase(),
            equals(message[0]),
          ); // Starts with capital
        }
      });
    });

    group('Value Range Tests', () {
      test('should have reasonable numeric values', () {
        // Icon sizes should be reasonable for UI
        expect(AppConstants.iconSizeSmall, greaterThanOrEqualTo(12.0));
        expect(AppConstants.iconSizeSmall, lessThanOrEqualTo(20.0));

        expect(AppConstants.iconSizeMedium, greaterThanOrEqualTo(20.0));
        expect(AppConstants.iconSizeMedium, lessThanOrEqualTo(30.0));

        expect(AppConstants.iconSizeLarge, greaterThanOrEqualTo(30.0));
        expect(AppConstants.iconSizeLarge, lessThanOrEqualTo(40.0));

        // Spacing should follow Material Design guidelines
        expect(AppConstants.spacingSmall, greaterThanOrEqualTo(4.0));
        expect(AppConstants.spacingMedium, greaterThanOrEqualTo(12.0));
        expect(AppConstants.spacingLarge, greaterThanOrEqualTo(20.0));
      });

      test('should have consistent proportions', () {
        // Icon sizes should have consistent ratio
        const smallToMedium =
            AppConstants.iconSizeMedium / AppConstants.iconSizeSmall;
        const mediumToLarge =
            AppConstants.iconSizeLarge / AppConstants.iconSizeMedium;

        expect(smallToMedium, closeTo(1.5, 0.1)); // Approximately 1.5x
        expect(mediumToLarge, closeTo(1.33, 0.1)); // Approximately 1.33x

        // Spacing should double
        expect(
          AppConstants.spacingMedium / AppConstants.spacingSmall,
          equals(2.0),
        );
        expect(
          AppConstants.spacingLarge / AppConstants.spacingSmall,
          equals(3.0),
        );
      });
    });

    group('Path and File Constants Tests', () {
      test('should have valid file paths', () {
        expect(AppConstants.defaultRingtonePath, contains('/'));
        expect(AppConstants.defaultRingtonePath, isNot(startsWith('/')));
        expect(AppConstants.defaultRingtonePath, isNot(endsWith('/')));
      });

      test('should use consistent path separators', () {
        expect(AppConstants.defaultRingtonePath.contains('\\'), isFalse);
        expect(AppConstants.defaultRingtonePath.contains('//'), isFalse);
      });
    });
  });
}
