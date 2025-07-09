# 🎵 Prévisualisation Audio - Beep Squared

## Fonctionnalité

### 🎧 **Aperçu des Sonneries**
L'application permet maintenant d'écouter un aperçu de chaque sonnerie avant de la sélectionner pour une alarme.

## Interface Utilisateur

### 🎮 **Contrôles Audio**
- **Bouton Play (▶️)** : Lance la prévisualisation de la sonnerie
- **Bouton Stop (⏹️)** : Arrête la prévisualisation en cours
- **Indication visuelle** : "♪ Playing..." s'affiche pendant la lecture
- **Tooltips** : "Play preview" / "Stop preview" pour l'accessibilité

### 🎨 **Design**
- **Couleurs intuitives** : Vert pour play, rouge pour stop
- **Feedback immédiat** : Changement d'icône instantané
- **Intégration fluide** : Boutons intégrés dans chaque ligne de sonnerie

## Comportement

### ⏱️ **Durée de Prévisualisation**
- **Limitation automatique** : Maximum 3 secondes par aperçu
- **Arrêt manuel** : Possibilité d'arrêter avant la fin
- **Une seule sonnerie** : Arrêt automatique de la précédente

### 🔄 **Gestion des États**
- **Sélection de sonnerie** : Arrêt automatique + fermeture dialogue
- **Fermeture dialogue** : Arrêt automatique de tout audio
- **Changement de sonnerie** : Arrêt de la précédente avant nouvelle lecture

## Types de Sonneries Supportées

### 📱 **Sonneries Intégrées**
- **Format** : Assets (MP3) intégrés dans l'application
- **Lecture** : Via `AssetSource` d'audioplayers
- **Exemples** : Alarm Clock, Bright Electronic, Melody Ring, etc.

### 🎵 **Sonneries Personnalisées**
- **Format** : Fichiers locaux importés par l'utilisateur
- **Lecture** : Via `DeviceFileSource` d'audioplayers
- **Vérification** : Existence du fichier avant lecture

### 🔔 **Son Par Défaut**
- **Comportement** : Joue un beep système (SystemSoundType.click)
- **Fallback** : Utilisé en cas d'erreur de lecture

## Architecture Technique

### 🏗️ **AudioPreviewService**
```dart
class AudioPreviewService {
  static AudioPreviewService get instance; // Singleton
  
  Future<void> playPreview(String soundPath); // Jouer aperçu
  Future<void> stopPreview();                 // Arrêter aperçu
  bool get isPlaying;                         // État de lecture
  String? get currentlyPlaying;               // Sonnerie en cours
}
```

### 🎛️ **Gestion des Resources**
- **AudioPlayer** : Instance unique réutilisée
- **Nettoyage automatique** : Arrêt lors du dispose()
- **Gestion d'erreurs** : Fallback sur son système

### 📱 **États du Widget**
```dart
class _RingtoneSelectionDialogState {
  String? _currentlyPreviewing; // Sonnerie en cours de prévisualisation
  
  Future<void> _togglePreview(String soundPath); // Basculer play/stop
}
```

## Gestion des Erreurs

### 🛡️ **Robustesse**
- **Fichiers manquants** : Fallback sur son système
- **Erreurs de lecture** : Catch + beep système
- **Resources indisponibles** : Affichage d'un message d'erreur

### 🔧 **Debugging**
- **Logs console** : Messages d'erreur détaillés
- **États visuels** : Indication claire de l'état de lecture

## Dépendances

### 📦 **Package audioplayers**
```yaml
audioplayers: ^5.0.0
```

### 🎯 **Sources Audio Supportées**
- `AssetSource` : Fichiers dans assets/
- `DeviceFileSource` : Fichiers locaux
- `SystemSound` : Sons système

## Améliorations Futures

### 🚀 **Fonctionnalités Potentielles**
- **Volume ajustable** : Slider de volume pour la prévisualisation
- **Fade in/out** : Transitions audio plus douces
- **Visualisation** : Indicateur de progression pendant la lecture
- **Loop** : Option de répétition pour les aperçus
- **Égaliseur** : Prévisualisation avec différents profils audio

### 📊 **Métriques**
- **Temps d'écoute** : Statistiques d'utilisation des aperçus
- **Sonneries populaires** : Tracking des plus écoutées
- **Préférences utilisateur** : Sauvegarde des préférences audio
