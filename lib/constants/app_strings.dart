/// Application text strings and localized content
class AppStrings {
  AppStrings._();

  // === APP INFORMATION ===
  static const String appName = 'Beep Squared';
  static const String appVersion = '1.0.0';

  // === NAVIGATION & GENERAL ===
  static const String settings = 'Settings';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String exit = 'Exit';
  static const String clearAll = 'Clear All';
  static const String about = 'About';
  static const String edit = 'Edit';
  static const String editAlarm = 'Edit';

  // === HOME SCREEN ===
  static const String noAlarmsMessage = 'No alarms set';
  static const String loadingAlarms = 'Loading alarms...';
  static const String createFirstAlarm =
      'Create your first alarm to get started.\nTap the button below to begin.';
  static const String addYourFirstAlarm = 'Add Your First Alarm';
  static const String addAlarm = 'Add Alarm';
  static String alarmCount(int count) => '$count alarm${count > 1 ? 's' : ''}';

  // === DIALOGS ===
  static const String exitApp = 'Exit App';
  static String exitAppConfirm(String appName) =>
      'Are you sure you want to exit $appName?';
  static const String deleteAlarm = 'Delete Alarm';
  static String deleteAlarmConfirm(String label) =>
      'Are you sure you want to delete the alarm "$label"?';
  static const String clearAllAlarms = 'Clear All Alarms';
  static const String clearAllAlarmsConfirm =
      'Are you sure you want to delete all alarms?';

  // === MESSAGES ===
  static String alarmSetFor(String time) => 'Alarm set for $time';
  static String alarmUpdatedFor(String time) => 'Alarm updated for $time';
  static const String alarmDeleted = 'Alarm deleted';
  static const String allAlarmsCleared = 'All alarms cleared';

  // === ERROR MESSAGES ===
  static const String alarmServiceLimitedMessage =
      'Some alarm features may be limited. Please restart the app if alarms don\'t work properly.';
  static const String alarmInitializationError = 'Alarm initialization error';
  static const String errorLoadingAlarms = 'Error loading alarms';
  static const String errorSavingAlarm = 'Error saving alarm';
  static const String errorSchedulingAlarm = 'Error scheduling alarm';
  static const String errorCancellingAlarm = 'Error cancelling alarm';

  // === SETTINGS SCREEN ===
  // === SNACKBAR MESSAGES ===
  static const String alarmSaved = 'Alarm saved';
  static const String settingsSaved = 'Settings saved';
  static const String themeUpdated = 'Theme updated';
  static const String eveningModeEnabled = 'Evening mode enabled';
  static const String dayModeEnabled = 'Day mode enabled';
  static const String automaticModeRestored = 'Automatic mode restored';
  static const String errorSavingSettings = 'Error saving settings';
  static const String adaptiveTheme = 'Adaptive Theme';
  static const String adaptiveThemeDescription =
      'Configure automatic color change schedule';
  static const String eveningModeStart = 'Evening mode start';
  static const String eveningModeEnd = 'Evening mode end';
  static String switchToOrangeTheme(String time) =>
      'Switch to orange theme at $time';
  static String switchToBlueTheme(String time) =>
      'Switch to blue theme at $time';
  static String basedOnCurrentTime(String time) =>
      'Based on current time: $time';
  static const String orangeThemeDescription =
      '🌙 The orange/warm evening theme promotes melatonin production and improves sleep quality';
  static const String blueThemeDescription =
      '☀️ The blue day theme stimulates alertness and energy';

  // === ADD/EDIT ALARM SCREEN ===
  static const String unlockMethod = 'Unlock Method';
  static const String mathConfiguration = 'Math Configuration';
  static const String difficulty = 'Difficulty:';
  static const String operations = 'Operations:';
  static const String weekend = 'Weekend';

  // === MATH DIFFICULTIES ===
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
  static const String difficultyEasyDesc = 'Simple calculations (1-50)';
  static const String difficultyMediumDesc = 'Medium calculations (1-100)';
  static const String difficultyHardDesc = 'Hard calculations (1-200)';

  // === MATH OPERATIONS ===
  static const String addition = 'Addition';
  static const String subtraction = 'Subtraction';
  static const String multiplication = 'Multiplication';
  static const String mixed = 'Mixed';
  static String mathLabel(String difficultyText) => 'Math ($difficultyText)';

  // === ALARM CARD ===
  static const String alarmTypeClassic = 'Classic';
  static const String alarmTypeMath = 'Math';
  static const String alarmOff = 'OFF';
  static const String soundTitle = 'Sound';
  static const String vibrate = 'Vibrate';

  // === MATH DIFFICULTY ===
  static const String mathEasy = 'Easy';
  static const String mathMedium = 'Medium';
  static const String mathHard = 'Hard';
  static String mathDifficultyDisplay(String difficulty) =>
      'Math ($difficulty)';

  // === ERROR MESSAGES ===
  static const String alarmFeaturesLimited =
      'Some alarm features may be limited. Please restart the app if alarms don\'t work properly.';
  static String alarmInitError(String error) =>
      'Alarm initialization error: $error';

  // === TOOLTIPS ===
  static const String addAlarmTooltip = 'Add alarm';
  static const String settingsTooltip = 'Settings';
  static const String saveTooltip = 'Save';

  // === ADD ALARM SCREEN ===
  static const String addAlarmTitle = 'Add Alarm';
  static const String editAlarmTitle = 'Edit Alarm';
  static const String discardChanges = 'Discard Changes?';
  static const String unsavedChangesMessage =
      'You have unsaved changes. Are you sure you want to leave?';
  static const String alarmTime = 'Alarm Time';
  static const String alarmLabel = 'Alarm Label';
  static const String enterAlarmName = 'Enter alarm name';
  static const String customDays = 'Custom Days';
  static const String deviceWillVibrate = 'Device will vibrate';
  static const String silentVibration = 'Silent vibration';
  static const String quickSelect = 'Quick Select';
  static const String selectAlarmTime = 'Select alarm time';
  static const String setTime = 'Set Time';
  static const String ok = 'OK';
  static const String selectRingtone = 'Select Ringtone';
  static const String importCustomRingtone = 'Import Custom Ringtone';
  static const String deleteRingtone = 'Delete Ringtone';
  static const String deleteRingtoneConfirm =
      'Are you sure you want to delete this custom ringtone?';
  static const String customRingtoneImported =
      'Custom ringtone imported successfully!';
  static const String customRingtoneDeleted =
      'Custom ringtone deleted successfully!';
  static const String errorImportingRingtone = 'Error importing ringtone';
  static const String pleaseEnterAlarmLabel = 'Please enter an alarm label';

  // === DEFAULT VALUES ===
  static const String defaultAlarmLabel = 'Alarm';
}
