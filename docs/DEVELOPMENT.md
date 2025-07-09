# 🛠️ Guide de Développement - Beep Squared

## 🚀 Démarrage Rapide

### Prérequis
- Flutter SDK 3.x+
- Android Studio / VS Code
- Git

### Installation
```bash
# Clone du projet
git clone <repo-url>
cd beep_squared

# Installation des dépendances
flutter pub get

# Lancement sur émulateur/device
flutter run
```

## 📋 Commandes Utiles

### Développement
```bash
# Hot reload
flutter run

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release

# Analyse du code
flutter analyze

# Tests
flutter test
```

### Nettoyage
```bash
# Nettoyage des builds
flutter clean

# Récupération des dépendances
flutter pub get

# Mise à jour des dépendances
flutter pub upgrade
```

## 🎯 Workflow de Développement

### 1. Ajout d'une Nouvelle Fonctionnalité
1. **Analyser** : Comprendre le besoin
2. **Planifier** : Définir l'architecture
3. **Implémenter** : Coder la fonctionnalité
4. **Tester** : Vérifier le fonctionnement
5. **Documenter** : Mettre à jour la documentation

### 2. Correction d'un Bug
1. **Reproduire** : Identifier le problème
2. **Localiser** : Trouver la source du bug
3. **Corriger** : Appliquer la solution
4. **Valider** : Tester la correction
5. **Documenter** : Mettre à jour les docs

## 🔧 Bonnes Pratiques

### Code Style
- **Formatting** : Utiliser `dart format`
- **Naming** : CamelCase pour les variables, PascalCase pour les classes
- **Comments** : Documenter les fonctions complexes
- **Structure** : Suivre l'architecture existante

### Architecture
- **Services** : Logique métier isolée
- **Widgets** : Composants réutilisables
- **Models** : Structures de données claires
- **Separation** : UI séparée de la logique

### Performance
- **Lazy Loading** : Chargement à la demande
- **Dispose** : Libération des ressources
- **Const** : Widgets constants quand possible
- **Keys** : Utiliser des clés pour les listes

## 🔍 Debugging

### Techniques
- **Print Statements** : `print('Debug: $value')`
- **Debugger** : Points d'arrêt dans l'IDE
- **Flutter Inspector** : Analyse de l'arbre des widgets
- **Logging** : Utiliser des niveaux de log

### Outils
- **Flutter DevTools** : Profiling et debugging
- **Android Studio** : Debugging Android
- **VS Code** : Extensions Flutter

## 📦 Gestion des Dépendances

### Ajout d'une Dépendance
```yaml
dependencies:
  new_package: ^1.0.0
```

### Mise à jour
```bash
flutter pub upgrade
```

### Problèmes Courants
- **Conflits de versions** : Vérifier les contraintes
- **Dépendances manquantes** : `flutter pub get`
- **Cache corrompu** : `flutter pub cache repair`

## 🎨 UI/UX Guidelines

### Design System
- **Couleurs** : Utiliser `Theme.of(context).colorScheme`
- **Typographie** : `Theme.of(context).textTheme`
- **Spacing** : Multiples de 8dp (8, 16, 24, 32)
- **Icons** : Material Icons ou cohérents

### Responsive Design
- **MediaQuery** : Adapter aux tailles d'écran
- **Flexible/Expanded** : Gestion de l'espace
- **Overflow** : Prévenir les débordements
- **Orientation** : Tester portrait/paysage

## 🧪 Tests

### Types de Tests
- **Unit Tests** : Logic des services
- **Widget Tests** : Composants UI
- **Integration Tests** : Flux complets

### Structure
```
test/
├── unit/
│   ├── services/
│   └── models/
├── widget/
│   └── widgets/
└── integration/
    └── app_test.dart
```

## 📱 Builds et Déploiement

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Debug IPA
flutter build ios --debug

# Release IPA
flutter build ios --release
```

## 🔧 Configuration

### Environnements
- **Development** : Hot reload, debugging
- **Staging** : Tests pré-production
- **Production** : Version finale

### Variables d'Environnement
```dart
// constants.dart
class Constants {
  static const bool isDebug = kDebugMode;
  static const String appVersion = '1.0.0';
}
```

## 📚 Ressources

### Documentation
- **Flutter** : https://flutter.dev/docs
- **Dart** : https://dart.dev/guides
- **Material Design** : https://material.io/

### Packages Utiles
- **flutter_local_notifications** : Notifications
- **shared_preferences** : Stockage local
- **file_picker** : Sélection de fichiers
- **audioplayers** : Lecture audio

## 🐛 Résolution de Problèmes

### Problèmes Courants
1. **Hot Reload ne fonctionne pas** : Redémarrer l'app
2. **Dependences non trouvées** : `flutter pub get`
3. **Erreurs de build** : `flutter clean`
4. **Performances lentes** : Vérifier les rebuilds

### Logs
```bash
# Logs Flutter
flutter logs

# Logs Android
adb logcat
```

## 🔄 Contribution

### Workflow Git
1. **Branch** : Créer une branche pour la feature
2. **Commit** : Messages clairs et descriptifs
3. **Push** : Pousser les changements
4. **Review** : Demander une revue de code
5. **Merge** : Fusionner après validation

### Format des Commits
```
feat: add ringtone preview functionality
fix: resolve overflow in alarm cards
docs: update architecture documentation
```
