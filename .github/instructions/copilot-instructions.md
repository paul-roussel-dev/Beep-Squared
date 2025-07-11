# 🤖 GitHub Copilot Instructions - Beep Squared

## 📋 Contexte du Projet
**Beep Squared** est une application de réveil Flutter moderne avec sonneries personnalisées, notifications robustes et interface Material Design. Le projet utilise une **architecture hybride Flutter + Android native** pour garantir la fiabilité des alarmes depuis l'arrière-plan, même avec l'écran verrouillé.

## 🏗️ Architecture Hybride & Structure

### Principe d'Organisation - Architecture Multi-Couches
- **Hybrid Architecture** : Flutter services + Android native AlarmManager pour fiabilité maximale
- **Separation of Concerns** : Logique métier séparée de l'UI, services natifs isolés
- **Services Pattern** : Singletons avec communication cross-platform
- **Repository Pattern** : Abstraction des données et persistance
- **Widget Composition** : Widgets réutilisables et modulaires
- **Method Channels** : Communication bidirectionnelle Flutter ↔ Android native

### Structure des Dossiers
```
lib/
├── main.dart                    # Point d'entrée avec initialisation services
├── models/                      # Modèles de données (Alarm avec JSON serilaization)
├── screens/                     # Écrans principaux (HomeScreen, AddAlarmScreen, AlarmScreen)
├── services/                    # Couche métier hybride
│   ├── alarm_service.dart           # CRUD opérations (SharedPreferences)
│   ├── alarm_scheduler_service.dart # Flutter notifications + scheduling
│   ├── android_alarm_service.dart   # Android native communication
│   ├── alarm_manager_service.dart   # UI management pour alarmes actives
│   ├── alarm_monitor_service.dart   # Background monitoring (Timer-based)
│   └── native_alarm_service.dart    # Alternative native service
├── widgets/                     # Composants réutilisables (AlarmCard, etc.)
└── utils/                       # Constantes, helpers, extensions

android/app/src/main/kotlin/com/example/beep_squared/
├── MainActivity.kt              # Entry point + MethodChannel setup
├── AlarmActivity.kt             # Full-screen alarm display
├── AlarmReceiver.kt             # BroadcastReceiver for alarms
└── AlarmService.kt              # Background Android service
```

### Architecture de Communication
```
Flutter Layer (Dart)
├── AlarmService (Data persistence)
├── AlarmSchedulerService (Notifications)
├── AndroidAlarmService (MethodChannel bridge)
└── AlarmManagerService (UI management)
           ↕ MethodChannel
Android Native Layer (Kotlin)
├── MainActivity (AlarmManager scheduling)
├── AlarmReceiver (Background triggers)
└── AlarmActivity (Lock screen display)
```

## 🎯 Standards de Code

### Naming Conventions
- **Classes** : PascalCase (`AlarmService`, `HomeScreen`)
- **Variables/Fonctions** : camelCase (`isEnabled`, `loadRingtones`)
- **Fichiers** : snake_case (`alarm_service.dart`, `home_screen.dart`)
- **Constantes** : lowerCamelCase (`defaultRingtonePath`, `appName`)

### Code Style
- **Formatting** : Toujours utiliser `dart format`
- **Imports** : Organiser par ordre (dart:, package:, relatif)
- **Comments** : Documenter les fonctions complexes et la logique métier
- **Const** : Utiliser `const` pour les widgets statiques

### Architecture Patterns
```dart
// Service Singleton Pattern
class AlarmService {
  static AlarmService? _instance;
  AlarmService._();
  static AlarmService get instance => _instance ??= AlarmService._();
}

// Hybrid Communication Pattern (MethodChannel)
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

// Background Monitoring Pattern
class AlarmMonitorService {
  Timer? _monitorTimer;
  
  void startMonitoring() {
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkAlarms(),
    );
  }
}

// Widget with callback Pattern
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

## 🎨 UI/UX Guidelines

### Material Design 3
- **Theme** : Utiliser `Theme.of(context).colorScheme`
- **Typography** : `Theme.of(context).textTheme`
- **Spacing** : Multiples de 8dp (8, 16, 24, 32)
- **Elevation** : Cohérent avec Material Design

### Responsive Design
- **MediaQuery** : Adapter aux tailles d'écran
- **Flexible/Expanded** : Gestion intelligente de l'espace
- **Overflow Prevention** : Toujours gérer les débordements avec `Flexible`, `Wrap`, `TextOverflow.ellipsis`

### Accessibility
- **Semantic Labels** : Utiliser `semanticsLabel` pour les icons
- **Contrast** : Respecter les ratios de contraste
- **Focus Management** : Navigation clavier appropriée

## 🔧 Gestion d'État & Services

### Services Architecture
```dart
// 1. AlarmService - Data Layer (CRUD)
class AlarmService {
  // SharedPreferences-based persistence
  Future<List<Alarm>> getAlarms() async { /* ... */ }
  Future<bool> addAlarm(Alarm alarm) async { /* ... */ }
  Future<bool> updateAlarm(Alarm updatedAlarm) async { /* ... */ }
  Future<bool> deleteAlarm(String alarmId) async { /* ... */ }
}

// 2. AlarmSchedulerService - Notification Layer
class AlarmSchedulerService {
  // Flutter Local Notifications + Timezone
  Future<void> scheduleAlarm(Alarm alarm) async { /* ... */ }
  Future<void> cancelAlarm(String alarmId) async { /* ... */ }
  DateTime _getNextAlarmTime(Alarm alarm) { /* ... */ }
}

// 3. AndroidAlarmService - Native Bridge
class AndroidAlarmService {
  // MethodChannel communication
  Future<void> scheduleAlarm(Alarm alarm, DateTime scheduledTime) async { /* ... */ }
  Future<void> _handleMethodCall(MethodCall call) async { /* ... */ }
}

// 4. AlarmManagerService - UI Management
class AlarmManagerService {
  // Alarm screen display and interaction
  Future<void> showAlarmScreen(Alarm alarm) async { /* ... */ }
  void _dismissAlarm(Alarm alarm) { /* ... */ }
  void _snoozeAlarm(Alarm alarm) { /* ... */ }
}

// 5. AlarmMonitorService - Background Monitoring
class AlarmMonitorService {
  // Timer-based monitoring for alarm triggers
  void startMonitoring() { /* ... */ }
  bool _shouldTriggerAlarm(Alarm alarm, DateTime now) { /* ... */ }
}
```

### Local State Pattern
```dart
class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  void _updateState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }
}
```

### Service Initialization Pattern
```dart
// In main.dart or HomeScreen
Future<void> _initializeAlarmServices() async {
  await AlarmSchedulerService.instance.initialize();
  await AndroidAlarmService.instance.initialize();
  AlarmManagerService.instance.setContext(context);
  AlarmMonitorService.instance.startMonitoring();
}
```

## 📱 Plateforme & Performance

### Hybrid Android Integration
- **MethodChannels** : Communication Flutter ↔ Android native via `beep_squared.alarm/native`
- **AlarmManager** : Android système pour alarmes exactes même en arrière-plan
- **BroadcastReceiver** : Réception des triggers d'alarme natifs
- **Permissions** : SCHEDULE_EXACT_ALARM, WAKE_LOCK, SYSTEM_ALERT_WINDOW
- **Lock Screen** : Affichage full-screen même avec écran verrouillé

### Cross-Platform Configuration
```kotlin
// MainActivity.kt - MethodChannel Setup
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
  .setMethodCallHandler { call, result ->
    when (call.method) {
      "scheduleAlarm" -> scheduleAlarm(...)
      "cancelAlarm" -> cancelAlarm(...)
    }
  }

// AlarmReceiver.kt - Background Trigger
override fun onReceive(context: Context, intent: Intent) {
  val alarmId = intent.getStringExtra("alarmId")
  val alarmIntent = Intent(context, AlarmActivity::class.java)
  context.startActivity(alarmIntent)
}
```

```xml
<!-- AndroidManifest.xml - Essential Permissions -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.DISABLE_KEYGUARD" />
<uses-permission android:name="android.permission.TURN_SCREEN_ON" />

<receiver android:name=".AlarmReceiver" android:exported="true" />
<activity android:name=".AlarmActivity" 
          android:showWhenLocked="true"
          android:turnScreenOn="true" />
```

### Performance Optimization
- **Lazy Loading** : Chargement des ressources à la demande
- **Background Monitoring** : Timer-based check every 5 seconds
- **Duplicate Prevention** : Alarm key tracking to prevent repeat triggers
- **Memory Management** : Cleanup of old triggered alarms

## 🔍 Gestion d'Erreurs

### Error Handling
```dart
Future<void> loadRingtones() async {
  try {
    final ringtones = await _loadFromAssets();
    _ringtones.addAll(ringtones);
  } catch (e) {
    debugPrint('Error loading ringtones: $e');
    // Fallback ou gestion d'erreur appropriée
  }
}
```

### User Feedback
- **Loading States** : Indicators pendant les opérations async
- **Error Messages** : Messages clairs et actionnables
- **Success Feedback** : Confirmation des actions importantes

## 🧪 Tests & Qualité

### Types de Tests
- **Unit Tests** : Services et logique métier
- **Widget Tests** : Composants UI
- **Integration Tests** : Flux utilisateur complets

### Code Quality
- **Dart Analyze** : Corriger tous les warnings
- **Code Coverage** : Viser 80%+ pour les services critiques
- **Documentation** : Commenter les APIs publiques

## 📦 Dépendances

### Gestion des Packages
- **pubspec.yaml** : Versions explicites et à jour
- **Dependencies** : Séparer dev_dependencies des dependencies
- **Licenses** : Vérifier la compatibilité des licences

### Packages Recommandés
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0     # Notifications systèmes
  shared_preferences: ^2.2.2               # Persistance locale
  file_picker: ^8.0.0                      # Sélection fichiers
  path_provider: ^2.1.0                    # Chemins système
  audioplayers: ^5.0.0                     # Audio playback
  timezone: ^0.9.2                         # Support timezone
  intl: ^0.19.0                            # Internationalisation
  cupertino_icons: ^1.0.8                  # Icons iOS-style
```

## 🚀 Déploiement

### Build Configuration
- **Release** : Optimisations activées
- **Obfuscation** : Code obfusqué pour la production
- **Signing** : Certificats de signature appropriés

### CI/CD
- **GitHub Actions** : Tests automatisés sur PR
- **Code Quality** : Linting et analyse automatique
- **Deployment** : Build et déploiement automatisés

## 🔄 Git Workflow

### Conventional Commits
```
feat: add ringtone preview functionality
fix: resolve overflow in alarm cards
docs: update architecture documentation
style: format code with dart format
refactor: extract alarm validation logic
test: add unit tests for AlarmService
chore: update dependencies
```

### Branch Strategy
- **main** : Production-ready code
- **develop** : Integration branch
- **feature/** : Feature branches
- **hotfix/** : Urgent fixes

## 🛡️ Sécurité & Bonnes Pratiques

### Data Security
- **Sensitive Data** : Jamais en dur dans le code
- **Permissions** : Principe du moindre privilège
- **Input Validation** : Validation côté client ET serveur

### Code Security
- **Dependencies** : Audit régulier des vulnérabilités
- **Secrets** : Utiliser des variables d'environnement
- **Logs** : Éviter les informations sensibles dans les logs

## 📚 Documentation

### Code Documentation
- **README** : Instructions claires de setup
- **API Docs** : Documenter les services publics
- **Architecture** : Diagrammes et explications

### User Documentation
- **Features** : Guide des fonctionnalités
- **Troubleshooting** : Solutions aux problèmes courants
- **Changelog** : Historique des versions

## 🎯 Objectifs de Qualité

### Metrics
- **Performance** : Temps de démarrage < 3s
- **Reliability** : Crash rate < 1%
- **Usability** : Navigation intuitive
- **Maintainability** : Code coverage > 80%

### Standards
- **Material Design** : Respect des guidelines
- **Accessibility** : WCAG 2.1 AA compliance
- **Performance** : 60fps stable
- **Battery** : Optimisation de la consommation

---

**Note** : Ces instructions guident le développement d'une application Flutter professionnelle. Adapter selon les besoins spécifiques du projet tout en maintenant la qualité et la cohérence.
