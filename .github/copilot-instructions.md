# 🤖 GitHub Copilot Instructions - Beep Squared

## 📋 Contexte du Projet
**Beep Squared** est une application de réveil Flutter moderne avec sonneries personnalisées, notifications robustes et interface Material Design. Le projet suit les standards professionnels Flutter avec une architecture en couches.

## 🏗️ Architecture & Structure

### Principe d'Organisation
- **Separation of Concerns** : Logique métier séparée de l'UI
- **Services Pattern** : Singletons pour la gestion centralisée
- **Repository Pattern** : Abstraction des données et persistance
- **Widget Composition** : Widgets réutilisables et modulaires

### Structure des Dossiers
```
lib/
├── main.dart              # Point d'entrée
├── models/               # Modèles de données (Alarm, etc.)
├── screens/              # Écrans principaux
├── services/             # Logique métier (AlarmService, RingtoneService)
├── widgets/              # Composants réutilisables
└── utils/                # Constantes, helpers, extensions
```

## 🎯 Standards de Code

### Naming Conventions
- **Classes** : PascalCase (`AlarmService`, `HomeScreen`)
- **Variables/Fonctions** : camelCase (`isEnabled`, `loadRingtones`)
- **Fichiers** : snake_case (`alarm_service.dart`, `home_screen.dart`)
- **Constantes** : UPPER_SNAKE_CASE (`DEFAULT_RINGTONE_PATH`)

### Code Style
- **Formatting** : Toujours utiliser `dart format`
- **Imports** : Organiser par ordre (dart:, package:, relatif)
- **Comments** : Documenter les fonctions complexes et la logique métier
- **Const** : Utiliser `const` pour les widgets statiques

### Architecture Patterns
```dart
// Service Singleton
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();
}

// Widget avec callback
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

## 🔧 Gestion d'État

### Local State
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

### Global State (Services)
```dart
class RingtoneService {
  static RingtoneService? _instance;
  static RingtoneService get instance => _instance ??= RingtoneService._();
  
  final List<String> _ringtones = [];
  List<String> get ringtones => List.unmodifiable(_ringtones);
}
```

## 📱 Plateforme & Performance

### Cross-Platform
- **Android** : Permissions dans `AndroidManifest.xml`
- **iOS** : Configuration dans `Info.plist`
- **Platform Channels** : Pour fonctionnalités natives si nécessaire

### Performance
- **Lazy Loading** : Chargement des ressources à la demande
- **Dispose** : Libération des ressources (Controllers, Streams)
- **Keys** : Utiliser des clés pour les listes dynamiques
- **Const Constructors** : Optimisation des rebuilds

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
  flutter_local_notifications: ^17.2.4  # Notifications
  shared_preferences: ^2.2.3            # Persistance
  file_picker: ^8.0.7                   # Sélection fichiers
  path_provider: ^2.1.4                 # Chemins système
  audioplayers: ^6.1.0                  # Audio
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
