# 🛠️ Guide de Développement

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter 3.32.5+**
- **Android Studio** / VS Code
- **Git**

### Installation
```bash
git clone <repo-url>
cd beep_squared
flutter pub get
flutter run
```

## 📋 Commandes Essentielles

```bash
# Développement
flutter run                    # Hot reload
flutter build apk --debug      # Build debug
flutter build apk --release    # Build production

# Maintenance
flutter clean                  # Nettoyage
flutter analyze               # Analyse code
flutter test                  # Tests
```

## 🏗️ Architecture

### Structure
- **lib/** : Code Flutter (Dart)
- **android/** : Code natif (Kotlin) 
- **assets/** : Ressources (sonneries MP3)

### Patterns
- **Singleton Services** : `instance` getter
- **MethodChannel** : Communication Flutter ↔ Android
- **Repository** : `AlarmService` pour données

## 🎯 Conventions

### Code Style
- `dart format` obligatoire
- Classes : `PascalCase`
- Variables : `camelCase`
- Fichiers : `snake_case`

### Git Workflow
```bash
git checkout -b feature/new-feature
git commit -m "feat: add new feature"
git push origin feature/new-feature
# → Pull Request
```

## 🔧 Tests

### Local
```bash
flutter test                   # Unit tests
flutter run --debug           # Test sur device
```

### Alarmes
⚠️ **Important** : Toujours tester les alarmes sur device réel (pas émulateur) pour valider la fiabilité native.

## 📚 Ressources

- **[Architecture](ARCHITECTURE.md)** : Structure technique
- **[Features](features/)** : Documentation fonctionnalités
- **[Fixes](fixes/)** : Corrections appliquées
