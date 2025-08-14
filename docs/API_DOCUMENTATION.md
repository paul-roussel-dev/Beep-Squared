# 📚 Beep Squared - API Documentation

## 🔧 Core Services

### AlarmService
```dart
/// Main service for alarm CRUD operations
class AlarmService {
  /// Get all alarms from persistent storage
  Future<List<Alarm>> getAlarms();
  
  /// Save alarm with validation
  Future<void> saveAlarm(Alarm alarm);
  
  /// Delete alarm and cancel notifications
  Future<void> deleteAlarm(String alarmId);
}
```

### AlarmSchedulerService
```dart
/// Handles alarm scheduling with Flutter Local Notifications
class AlarmSchedulerService {
  /// Schedule alarm with Android native backup
  Future<void> scheduleAlarm(Alarm alarm);
  
  /// Cancel both Flutter and Android native alarms
  Future<void> cancelAlarm(String alarmId);
}
```

### AndroidAlarmService (MethodChannel)
```dart
/// Native Android alarm management
class AndroidAlarmService {
  /// Schedule alarm with AlarmManager
  Future<void> scheduleAlarm(String alarmId, DateTime scheduledTime);
  
  /// Cancel native Android alarm
  Future<void> cancelAlarm(String alarmId);
}
```

## 🎨 UI Components

### AlarmCard
```dart
/// Reusable alarm display widget
class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
}
```

### Theme Management
```dart
/// Adaptive theming service
class ThemeManager {
  /// Get current theme based on time settings
  ThemeData getCurrentTheme();
  
  /// Check if evening mode should be active
  bool get effectiveIsEveningTime;
}
```

## 🏗️ Architecture Patterns

### Singleton Services
All services use singleton pattern with `instance` getter:
```dart
AlarmService.instance.getAlarms()
AlarmSchedulerService.instance.scheduleAlarm(alarm)
ThemeManager.instance.getCurrentTheme()
```

### Constants Architecture
Centralized constants in `/lib/constants/`:
- `AppStrings` - All UI text
- `AppColors` - Adaptive color system
- `AppSizes` - Spacing and dimensions

### Method Channels
Flutter ↔ Android communication via:
```dart
static const MethodChannel _channel = MethodChannel('beep_squared.alarm/native');
```

## 🔧 Configuration

### Alarm Types
```dart
enum AlarmUnlockMethod {
  simple,  // Tap to dismiss
  math,    // Solve math problem
}

enum MathDifficulty {
  easy,    // Single digit addition
  medium,  // Two digit operations
  hard,    // Complex calculations
}
```

### Notification Configuration
```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'alarm_channel',
  'Alarms',
  channelDescription: 'Alarm notifications',
  importance: Importance.max,
  priority: Priority.high,
  fullScreenIntent: true,
);
```
