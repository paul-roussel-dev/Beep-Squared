# 📋 Directives de Codage - Beep Squared

Vous êtes GitHub Copilot, assistant de développement pour l'application **Beep Squared**, une application de réveil Flutter moderne avec architecture hybride Flutter + Android native.

## 🏗️ Architecture du Projet

### Stack Technique
- **Framework** : Flutter (Dart 3.8.1+)
- **Architecture** : Hybride Flutter + Android native avec MethodChannels
- **Persistance** : SharedPreferences
- **Notifications** : flutter_local_notifications + Android AlarmManager
- **Audio** : audioplayers + assets
- **UI** : Material Design 3

### Patterns Architecturaux
- **Singleton Services** : Instance unique via `instance` getter
- **Repository Pattern** : Abstraction des données (AlarmService)
- **Method Channels** : Communication Flutter ↔ Android native
- **Widget Composition** : Composants réutilisables avec callbacks
- **Separation of Concerns** : UI, logique métier, données séparées

## 🎯 Conventions de Nommage

### Dart/Flutter
- **Classes** : PascalCase (`AlarmService`, `HomeScreen`, `AlarmCard`)
- **Variables/Fonctions** : camelCase (`isEnabled`, `loadRingtones`, `_selectedTime`)
- **Fichiers** : snake_case (`alarm_service.dart`, `home_screen.dart`)
- **Constantes** : lowerCamelCase (`defaultRingtonePath`, `appName`)
- **Privé** : Préfixe underscore (`_instance`, `_loadAlarms()`)

### Structure des Dossiers
```
lib/
├── main.dart                    # Point d'entrée + initialisation services
├── models/                      # Modèles de données (Alarm, etc.)
├── screens/                     # Écrans (HomeScreen, AddAlarmScreen)
├── services/                    # Logique métier + communication native
├── widgets/                     # Composants réutilisables
└── utils/                       # Constantes, helpers, extensions
```

## 🔧 Standards de Code

### Format et Style
- **Formatting** : Toujours utiliser `dart format`
- **Imports** : Ordre (dart:, package:, relatif)
- **Documentation** : Commenter les APIs publiques et logique complexe
- **Const** : Utiliser `const` pour les widgets statiques

### Exemple de Service Singleton
```dart
class AlarmService {
  static AlarmService? _instance;
  AlarmService._();
  static AlarmService get instance => _instance ??= AlarmService._();
  
  /// Get all alarms from persistent storage
  Future<List<Alarm>> getAlarms() async {
    // Implementation with error handling
  }
}
```

### Gestion d'État et UI
```dart
class MyWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final String title;
  
  const MyWidget({
    super.key,
    required this.title,
    this.onPressed,
  });
}

class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.title),
        onTap: widget.onPressed,
      ),
    );
  }
}
```

## 🎨 UI/UX Guidelines

### Material Design 3
- **Theme** : `Theme.of(context).colorScheme`
- **Typography** : `Theme.of(context).textTheme`
- **Spacing** : Multiples de 8dp via `AppConstants`
- **Elevation** : Respecter Material Design 3

### Responsive et Accessibilité
```dart
Widget build(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Column(
        children: [
          Flexible(
            child: Text(
              alarm.label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Gestion des Overflow
- **Flexible/Expanded** : Pour adaptation espace
- **TextOverflow.ellipsis** : Textes longs
- **Wrap** : Retour à la ligne automatique
- **SingleChildScrollView** : Contenu défilable

## 🔧 Services et Communication Native

### Pattern MethodChannel
```dart
class AndroidAlarmService {
  static const MethodChannel _channel = MethodChannel('beep_squared.alarm/native');
  
  Future<void> scheduleAlarm(Alarm alarm, DateTime scheduledTime) async {
    await _channel.invokeMethod('scheduleAlarm', {
      'alarmId': alarm.id,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'label': alarm.label,
    });
  }
}
```

### Gestion d'Erreurs
- **Try-catch** : Systématique pour opérations async
- **Null safety** : Respecter null safety de Dart
- **Validation** : Inputs utilisateur
- **Fallback** : Plans B en cas d'échec

## 🧪 Qualité et Tests

### Principes
- **Single Responsibility** : Une classe = une responsabilité
- **DRY** : Don't Repeat Yourself
- **Error Handling** : Gestion robuste des erreurs
- **Performance** : Lazy loading, dispose resources

### Tests Recommandés
- **Unit Tests** : Services et logique métier
- **Widget Tests** : Composants UI
- **Integration Tests** : Flux utilisateur complets

## 📱 Spécificités Plateformes

### Android Native (Kotlin)
- **Architecture** : AlarmManager + BroadcastReceiver + Services
- **Permissions** : WAKE_LOCK, RECEIVE_BOOT_COMPLETED
- **Lifecycle** : Gestion correcte des services Android

### Communication Flutter ↔ Native
- **MethodChannel** : Pour appels depuis Flutter
- **EventChannel** : Pour stream d'événements
- **Data Types** : Maps pour structures complexes

## 🔄 Patterns de Développement

### Initialisation des Services
```dart
// Dans main.dart
Future<void> _initializeNativeServices() async {
  try {
    await AndroidAlarmService.instance.initialize();
    AlarmMonitorService.instance.startMonitoring();
  } catch (e) {
    debugPrint('Error initializing services: $e');
    // Fallback behavior
  }
}
```

### Widgets avec Callbacks
```dart
class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const AlarmCard({
    super.key,
    required this.alarm,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });
}
```

## 🎯 Priorités de Développement

1. **Robustesse** : Fiabilité des alarmes avant tout
2. **UX** : Interface intuitive et responsive
3. **Performance** : Optimisation mémoire et batterie
4. **Maintenabilité** : Code propre et documenté
5. **Testing** : Couverture des cas critiques

---

**Rappel** : Ce projet privilégie la fiabilité des alarmes avec une architecture hybride. Toujours tester les fonctionnalités d'alarme sur device réel, et maintenir la compatibilité entre les couches Flutter et Android native.
