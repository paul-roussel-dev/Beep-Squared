import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Service for previewing audio ringtones
/// 
/// This service provides functionality to preview ringtones for a limited
/// duration (3 seconds) to help users choose their preferred sound.
class AudioPreviewService {
  static AudioPreviewService? _instance;
  late AudioPlayer _audioPlayer;
  String? _currentlyPlaying;
  
  /// Private constructor to prevent direct instantiation
  AudioPreviewService._() {
    _audioPlayer = AudioPlayer();
  }
  
  /// Singleton instance accessor
  static AudioPreviewService get instance {
    _instance ??= AudioPreviewService._();
    return _instance!;
  }

  /// Play a ringtone preview (limited to configured duration)
  Future<void> playPreview(String soundPath) async {
    try {
      // Stop any currently playing sound
      await stopPreview();
      
      if (soundPath.isEmpty) {
        // Default system sound - play a short beep
        await _playSystemBeep();
        return;
      }
      
      _currentlyPlaying = soundPath;
      
      if (soundPath.startsWith('assets/')) {
        // Built-in app ringtone
        await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      } else {
        // Custom ringtone (local file)
        final file = File(soundPath);
        if (await file.exists()) {
          await _audioPlayer.play(DeviceFileSource(soundPath));
        }
      }
      
      // Auto-stop after preview duration
      Future.delayed(Duration(seconds: AppConstants.previewDurationSeconds), () {
        if (_currentlyPlaying == soundPath) {
          stopPreview();
        }
      });
      
    } catch (e) {
      debugPrint('Error playing preview: $e');
      // On error, play system beep as fallback
      await _playSystemBeep();
    }
  }

  /// Stop the current preview
  Future<void> stopPreview() async {
    try {
      await _audioPlayer.stop();
      _currentlyPlaying = null;
    } catch (e) {
      debugPrint('Error stopping preview: $e');
    }
  }

  /// Play a system beep for default sound
  Future<void> _playSystemBeep() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing system beep: $e');
    }
  }

  /// Check if a sound is currently playing
  bool get isPlaying => _currentlyPlaying != null;
  
  /// Get the path of the currently playing sound
  String? get currentlyPlaying => _currentlyPlaying;

  /// Clean up resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
