# Beep Squared 🔔

Une application de réveil moderne avec **architecture hybride Flutter + Android native** et défis mathématiques.

## 🚀 Démarrage Rapide

Application de réveil cross-platform avec fiabilité maximale grâce à l'intégration native Android et interface moderne.

### Installation

1. Assurez-vous d'avoir Flutter installé (3.32.5+)
2. Exécutez `flutter pub get` pour installer les dépendances
3. Exécutez `flutter run` pour démarrer l'application

### Build Production

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## ✨ Fonctionnalités

### 🔐 Systèmes de Déverrouillage

- **Simple** : Bouton dismiss classique
- **Math Challenge** : Défis mathématiques (addition, soustraction, multiplication)
  - 3 niveaux de difficulté (Easy, Medium, Hard)
  - Interface numérique moderne avec bouton aléatoire

### ⏰ Gestion Avancée des Alarmes

- **Alarmes multiples** : Création et gestion illimitée
- **Récurrence flexible** : Par jours de la semaine
- **Snooze intelligent** : Notification avec heure de prochaine sonnerie
- **Fiabilité maximale** : Architecture hybride Flutter + Android native

### 🎵 Système Audio Complet

- **7 sonneries intégrées** : Sons d'alarme optimisés
- **Prévisualisation** : Écoute avant sélection
- **Volume ALARM** : Utilisation du stream système approprié

### 🎨 Interface Moderne

- **Material Design 3** : Design system moderne
- **Thème bleu/blanc/gris** : Interface unifiée
- **Interface native** : AlarmOverlayService full-screen
- **Responsive** : Gestion des débordements et adaptation écrans

## 🏗️ Architecture Hybride

### Communication Multi-Couches

```
Flutter Layer (Dart) ←→ Android Native (Kotlin)
     MethodChannel        AlarmManager
   Notifications        BroadcastReceiver
  UI Management         Full-screen Overlay
```

### Fiabilité Maximale

- **Android AlarmManager** : Déclenchement même app fermée
- **Background Monitoring** : Surveillance Timer-based de secours
- **Permissions optimales** : SCHEDULE_EXACT_ALARM, WAKE_LOCK, SYSTEM_ALERT_WINDOW

## 📚 Documentation

### 📋 Documentation Principale

- **[Architecture Technique](docs/ARCHITECTURE.md)** - Structure hybride et patterns
- **[Guide de Développement](docs/DEVELOPMENT.md)** - Workflow et bonnes pratiques
- **[Restructuration Kotlin](docs/KOTLIN_RESTRUCTURE.md)** - Architecture native

### 🔧 Fonctionnalités et Corrections

- **[Prévisualisation Audio](docs/features/AUDIO_PREVIEW.md)** - Système d'écoute
- **[Gestion des Sonneries](docs/features/RINGTONES.md)** - Assets et prévisualisation
- **[Correction Overflow](docs/fixes/OVERFLOW_FIX.md)** - Interface responsive
- **[Navigation](docs/fixes/NAVIGATION.md)** - Gestion bouton retour

## 🔧 Stack Technique

### Frontend

- **Flutter 3.32.5+** : Framework UI cross-platform
- **Material Design 3** : Design system moderne
- **Dart 3.8.1+** : Langage avec null safety

### Backend & Native

- **Android Kotlin** : Couche native pour fiabilité
- **MethodChannel** : Communication Flutter ↔ Android
- **AlarmManager** : Système d'alarmes Android

### Services & Packages

- **flutter_local_notifications** : Notifications système
- **audioplayers** : Lecture audio avec gestion mémoire
- **shared_preferences** : Persistance locale JSON

## 🎯 Patterns Architecturaux

- **Singleton Services** : Instance unique via `instance` getter
- **Repository Pattern** : Abstraction données (AlarmService)
- **MethodChannel Pattern** : Communication hybrid
- **Observer Pattern** : Monitoring et callbacks
- **Command Pattern** : Actions encapsulées

## 🚀 Performance & Optimisation

### ⚡ Optimisations Appliquées

- **Native Priority** : AlarmManager pour 99.9% fiabilité
- **Memory Management** : Cleanup automatique ressources
- **Background Monitoring** : Vérifications 5s comme backup
- **Lazy Loading** : Chargement ressources à la demande

### 📊 Métriques Qualité

- **Démarrage** : < 3 secondes
- **Interface** : 60fps fluides
- **Fiabilité** : Architecture hybride garantie
- **UX** : Interface moderne intuitive

## 🤝 Contribution

Les contributions sont bienvenues ! Consultez le [Guide de Développement](docs/DEVELOPMENT.md) pour commencer.

### Workflow Recommandé

1. Fork du projet
2. Branche feature : `git checkout -b feature/amazing-feature`
3. Commit : `git commit -m 'Add amazing feature'`
4. Push : `git push origin feature/amazing-feature`
5. Pull Request

---

🔔 **Beep Squared** - L'application de réveil qui ne vous laissera jamais en retard !

---

Pour plus d'aide sur le développement Flutter, consultez la
[documentation officielle](https://docs.flutter.dev/).
