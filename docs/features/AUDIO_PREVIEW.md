# 🎵 Prévisualisation Audio

## 🎯 Fonctionnalité

Écoute des sonneries avant sélection avec contrôles intuitifs et limitation automatique.

## 🎮 Interface

### Contrôles
- **▶️ Play** : Lance l'aperçu (max 3s)
- **⏹️ Stop** : Arrêt manuel
- **Feedback** : "♪ Playing..." pendant lecture

### Comportement
- **Une seule sonnerie** : Arrêt automatique de la précédente
- **Sélection** : Arrêt auto + fermeture dialogue
- **Fermeture** : Cleanup automatique

## 🎵 Sonneries Supportées

- **Assets intégrés** : 7 sonneries MP3 pré-installées
- **Fichiers locaux** : Import utilisateur (futur)
- **Fallback** : Beep système si erreur

## ⚙️ Implémentation

Service `AudioPreviewService` avec gestion mémoire automatique et cleanup des ressources.

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
