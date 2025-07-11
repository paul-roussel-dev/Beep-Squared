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
      Future.delayed(const Duration(seconds: AppConstants.previewDurationSeconds), () {
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
      if (_currentlyPlaying != null) {
        debugPrint('Stopping audio preview: $_currentlyPlaying');
        await _audioPlayer.stop();
        _currentlyPlaying = null;
      }
    } catch (e) {
      debugPrint('Error stopping preview: $e');
      _currentlyPlaying = null; // Reset state even on error
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

  /// Play alarm sound in loop until stopped
  Future<void> playAlarmLoop(String soundPath) async {
    try {
      // Stop any currently playing sound
      await stopPreview();
      
      if (soundPath.isEmpty) {
        // Default system sound - play a short beep repeatedly
        await _playSystemBeepLoop();
        return;
      }
      
      _currentlyPlaying = soundPath;
      
      // Set player to loop mode
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
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
      
    } catch (e) {
      debugPrint('Error playing alarm loop: $e');
      // On error, play system beep as fallback
      await _playSystemBeepLoop();
    }
  }

  /// Play system beep in loop for default alarm sound
  Future<void> _playSystemBeepLoop() async {
    // This is a simple implementation - in production you might want
    // to use a proper looping mechanism
    _currentlyPlaying = 'system_beep_loop';
    _startSystemBeepLoop();
  }

  void _startSystemBeepLoop() {
    if (_currentlyPlaying == 'system_beep_loop') {
      SystemSound.play(SystemSoundType.click);
      Future.delayed(const Duration(seconds: 1), () {
        _startSystemBeepLoop();
      });
    }
  }
}
