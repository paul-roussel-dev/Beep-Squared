import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioPreviewService {
  static AudioPreviewService? _instance;
  late AudioPlayer _audioPlayer;
  String? _currentlyPlaying;
  
  AudioPreviewService._() {
    _audioPlayer = AudioPlayer();
  }
  
  static AudioPreviewService get instance {
    _instance ??= AudioPreviewService._();
    return _instance!;
  }

  // Jouer un aperçu de sonnerie (3 secondes max)
  Future<void> playPreview(String soundPath) async {
    try {
      // Arrêter le son précédent s'il y en a un
      await stopPreview();
      
      if (soundPath.isEmpty) {
        // Son par défaut du système - jouer un beep court
        await _playSystemBeep();
        return;
      }
      
      _currentlyPlaying = soundPath;
      
      if (soundPath.startsWith('assets/')) {
        // Sonnerie intégrée dans l'app
        await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      } else {
        // Sonnerie personnalisée (fichier local)
        final file = File(soundPath);
        if (await file.exists()) {
          await _audioPlayer.play(DeviceFileSource(soundPath));
        }
      }
      
      // Arrêter automatiquement après 3 secondes pour un aperçu
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentlyPlaying == soundPath) {
          stopPreview();
        }
      });
      
    } catch (e) {
      print('Error playing preview: $e');
      // En cas d'erreur, jouer un beep système
      await _playSystemBeep();
    }
  }

  // Arrêter la prévisualisation
  Future<void> stopPreview() async {
    try {
      await _audioPlayer.stop();
      _currentlyPlaying = null;
    } catch (e) {
      print('Error stopping preview: $e');
    }
  }

  // Jouer un beep système pour le son par défaut
  Future<void> _playSystemBeep() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing system beep: $e');
    }
  }

  // Vérifier si un son est en cours de lecture
  bool get isPlaying => _currentlyPlaying != null;
  
  // Obtenir le chemin du son en cours de lecture
  String? get currentlyPlaying => _currentlyPlaying;

  // Nettoyer les ressources
  void dispose() {
    _audioPlayer.dispose();
  }
}
