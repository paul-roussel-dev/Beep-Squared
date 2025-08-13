import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:beep_squared/constants/constants.dart';

void main() {
  group('Constants Tests', () {
    group('App Information Tests', () {
      test('should have valid app name', () {
        expect(AppStrings.appName, isNotEmpty);
        expect(AppStrings.appName, equals('Beep Squared'));
      });

      test('should have valid app version', () {
        expect(AppStrings.appVersion, isNotEmpty);
        expect(AppStrings.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
        expect(AppStrings.appVersion, equals('1.0.0'));
      });
    });

    group('Spacing Constants Tests', () {
      test('should have consistent spacing values', () {
        expect(AppSizes.spacingSmall, lessThan(AppSizes.spacingMedium));
        expect(AppSizes.spacingMedium, lessThan(AppSizes.spacingLarge));

        // Check actual values
        expect(AppSizes.spacingSmall, equals(8.0));
        expect(AppSizes.spacingMedium, equals(16.0));
        expect(AppSizes.spacingLarge, equals(24.0));
      });

      test('should have positive spacing values', () {
        expect(AppSizes.spacingSmall, greaterThan(0));
        expect(AppSizes.spacingMedium, greaterThan(0));
        expect(AppSizes.spacingLarge, greaterThan(0));
      });

      test('should follow 8dp grid system', () {
        expect(AppSizes.spacingSmall % 8, equals(0));
        expect(AppSizes.spacingMedium % 8, equals(0));
        expect(AppSizes.spacingLarge % 8, equals(0));
      });
    });

    group('Icon Size Constants Tests', () {
      test('should have consistent icon size progression', () {
        expect(AppSizes.iconSmall, lessThan(AppSizes.iconMedium));
        expect(AppSizes.iconMedium, lessThan(AppSizes.iconLarge));

        // Check actual values
        expect(AppSizes.iconSmall, equals(16.0));
        expect(AppSizes.iconMedium, equals(20.0));
        expect(AppSizes.iconLarge, equals(24.0));
      });

      test('should have positive icon sizes', () {
        expect(AppSizes.iconSmall, greaterThan(0));
        expect(AppSizes.iconMedium, greaterThan(0));
        expect(AppSizes.iconLarge, greaterThan(0));
      });
    });

    group('Color Constants Tests', () {
      test('should have valid primary colors', () {
        expect(AppColors.dayPrimary, isA<Color>());
        expect(AppColors.eveningPrimary, isA<Color>());
        expect(AppColors.white, equals(const Color(0xFFFFFFFF)));
        expect(AppColors.black, equals(const Color(0xFF000000)));
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
        expect(AppStrings.noAlarmsMessage, isNotEmpty);
        expect(AppStrings.addAlarm, isNotEmpty);
        expect(AppStrings.settings, isNotEmpty);
        expect(AppStrings.cancel, isNotEmpty);
        expect(AppStrings.delete, isNotEmpty);

        // Check actual values
        expect(AppStrings.noAlarmsMessage, equals('No alarms set'));
        expect(AppStrings.addAlarm, equals('Add Alarm'));
        expect(AppStrings.settings, equals('Settings'));
        expect(AppStrings.cancel, equals('Cancel'));
        expect(AppStrings.delete, equals('Delete'));
      });

      test('UI messages should be user-friendly', () {
        final messages = [
          AppStrings.noAlarmsMessage,
          AppStrings.addAlarm,
          AppStrings.settings,
          AppStrings.cancel,
          AppStrings.delete,
        ];

        for (final message in messages) {
          expect(message.length, greaterThan(2)); // Not too short
          expect(message.length, lessThan(50)); // Not too long
        }
      });
    });

    group('Value Range Tests', () {
      test('should have reasonable numeric values', () {
        // Icon sizes should be reasonable for UI
        expect(AppSizes.iconSmall, greaterThanOrEqualTo(12.0));
        expect(AppSizes.iconSmall, lessThanOrEqualTo(20.0));

        expect(AppSizes.iconMedium, greaterThanOrEqualTo(18.0));
        expect(AppSizes.iconMedium, lessThanOrEqualTo(25.0));

        expect(AppSizes.iconLarge, greaterThanOrEqualTo(22.0));
        expect(AppSizes.iconLarge, lessThanOrEqualTo(30.0));

        // Spacing should follow Material Design guidelines
        expect(AppSizes.spacingSmall, greaterThanOrEqualTo(4.0));
        expect(AppSizes.spacingMedium, greaterThanOrEqualTo(12.0));
        expect(AppSizes.spacingLarge, greaterThanOrEqualTo(20.0));
      });

      test('should have consistent proportions', () {
        // Spacing should have consistent ratios
        expect(AppSizes.spacingMedium / AppSizes.spacingSmall, equals(2.0));
        expect(AppSizes.spacingLarge / AppSizes.spacingSmall, equals(3.0));
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

    group('Theme Colors Tests', () {
      test('should have valid theme colors', () {
        expect(AppColors.dayPrimary, isA<Color>());
        expect(AppColors.eveningPrimary, isA<Color>());

        // Day theme should be blue-ish
        expect(
          AppColors.dayPrimary.blue,
          greaterThan(AppColors.dayPrimary.red),
        );

        // Evening theme should be orange-ish
        expect(
          AppColors.eveningPrimary.red,
          greaterThan(AppColors.eveningPrimary.blue),
        );
      });
    });
  });
}
