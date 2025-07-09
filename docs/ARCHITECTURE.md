# 🏗️ Architecture Technique - Beep Squared

## 📋 Vue d'ensemble
Cette documentation décrit l'architecture technique de l'application Beep Squared, une application de réveil Flutter avec sonneries personnalisées.

## 🎯 Structure du Projet

### 📁 Dossiers Principaux
```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/
│   └── alarm.dart           # Modèle de données pour les alarmes
├── screens/
│   ├── home_screen.dart     # Écran principal avec liste des alarmes
│   └── add_alarm_screen.dart # Écran d'ajout/modification d'alarme
├── services/
│   ├── alarm_service.dart         # Service de gestion des alarmes
│   ├── ringtone_service.dart      # Service de gestion des sonneries
│   └── audio_preview_service.dart # Service de prévisualisation audio
├── utils/
│   └── constants.dart       # Constantes de l'application
└── widgets/
    └── alarm_card.dart      # Widget pour afficher une alarme
```

## 🔧 Services

### AlarmService
- **Responsabilité** : Gestion des alarmes et notifications
- **Fonctionnalités** : 
  - Création/modification/suppression d'alarmes
  - Planification des notifications
  - Persistance via SharedPreferences

### RingtoneService
- **Responsabilité** : Gestion des sonneries (assets + personnalisées)
- **Fonctionnalités** :
  - Chargement des sonneries par défaut (assets)
  - Import de sonneries personnalisées
  - Suppression de sonneries importées
  - Noms d'affichage conviviaux

### AudioPreviewService
- **Responsabilité** : Prévisualisation audio des sonneries
- **Fonctionnalités** :
  - Lecture de sonneries (3 secondes)
  - Gestion des états play/stop
  - Support assets et fichiers locaux

## 🎨 Interface Utilisateur

### Navigation
- **WillPopScope** : Gestion du bouton retour Android
- **Confirmations** : Dialogues pour changements non sauvegardés
- **États** : Gestion des états de navigation

### Responsive Design
- **Overflow** : Gestion avec Flexible et TextOverflow.ellipsis
- **Wrap** : Retour à la ligne automatique pour les éléments
- **MediaQuery** : Adaptation aux tailles d'écran

## 🔄 Flux de Données

### Création d'Alarme
1. **Utilisateur** → `AddAlarmScreen`
2. **Sélection Sonnerie** → `RingtoneService`
3. **Prévisualisation** → `AudioPreviewService`
4. **Sauvegarde** → `AlarmService`
5. **Notification** → `flutter_local_notifications`

### Gestion des Sonneries
1. **Chargement** → `RingtoneService.loadRingtones()`
2. **Import** → `file_picker` + `path_provider`
3. **Stockage** → Dossier application + `SharedPreferences`
4. **Suppression** → Fichier + préférences

## 🔧 Dépendances Techniques

### Core Flutter
- **flutter_local_notifications** : Notifications et alarmes
- **shared_preferences** : Persistance des données

### Gestion Fichiers
- **file_picker** : Sélection de fichiers audio
- **path_provider** : Chemins des dossiers système

### Audio
- **audioplayers** : Lecture et prévisualisation audio

## 📱 Plateformes Supportées

### Android
- **NDK** : Auto-sélection pour compatibilité
- **Permissions** : Notifications, stockage, audio
- **Build** : Gradle avec optimisations

### iOS
- **Permissions** : Notifications, stockage
- **Framework** : Core Audio support

## 🔍 Patterns Utilisés

### Singleton
- **Services** : Instance unique via `instance` getter
- **Avantages** : État global, économie mémoire

### State Management
- **StatefulWidget** : Gestion d'état local
- **Callbacks** : Communication parent-enfant

### Async/Await
- **Opérations** : Fichiers, audio, notifications
- **Gestion d'erreurs** : Try-catch blocks

## 🛡️ Gestion d'Erreurs

### Validation
- **Entrées utilisateur** : Validation des heures, libellés
- **Fichiers** : Vérification format et taille

### Exceptions
- **Audio** : Gestion des erreurs de lecture
- **Fichiers** : Gestion des permissions et accès
- **Notifications** : Fallback si échec

## 🔧 Configuration

### Assets
```yaml
flutter:
  assets:
    - assets/sounds/
```

### Permissions Android
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

## 📊 Performance

### Optimisations
- **Lazy Loading** : Chargement des sonneries à la demande
- **Dispose** : Libération des ressources audio
- **Caching** : Mise en cache des informations sonneries

### Mémoire
- **Singletons** : Évite les instances multiples
- **Audio** : Libération automatique après prévisualisation
