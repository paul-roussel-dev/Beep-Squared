import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/constants.dart';

/// Service for managing ringtones (default and custom)
/// 
/// This service handles loading default ringtones from assets,
/// importing custom ringtones, and managing their persistence.
class RingtoneService {
  static RingtoneService? _instance;
  
  /// Private constructor to prevent direct instantiation
  RingtoneService._();
  
  /// Singleton instance accessor
  static RingtoneService get instance {
    _instance ??= RingtoneService._();
    return _instance!;
  }

  /// Default ringtones available from assets
  List<Map<String, String>> get defaultRingtones => [
    {'name': 'Alarm Clock', 'path': 'assets/sounds/alarm-clock-short-6402.mp3', 'type': 'asset'},
    {'name': 'Bright Electronic', 'path': 'assets/sounds/bright-electronic-loop-251871.mp3', 'type': 'asset'},
    {'name': 'Level Up', 'path': 'assets/sounds/level-up-06-370051.mp3', 'type': 'asset'},
    {'name': 'Melody Ring', 'path': 'assets/sounds/melody-ring-tone-313022.mp3', 'type': 'asset'},
    {'name': 'Original Phone', 'path': 'assets/sounds/original-phone-ringtone-36558.mp3', 'type': 'asset'},
    {'name': 'Ringtone', 'path': 'assets/sounds/ringtone-249206.mp3', 'type': 'asset'},
    {'name': 'Soft Ring', 'path': 'assets/sounds/soft-ring-tone-313009.mp3', 'type': 'asset'},
  ];

  /// Get custom ringtones from storage
  Future<List<Map<String, String>>> getCustomRingtones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customRingtonesJson = prefs.getString(AppConstants.customRingtonesKey);
      
      if (customRingtonesJson == null) return [];
      
      final List<dynamic> customRingtonesList = json.decode(customRingtonesJson);
      return customRingtonesList.cast<Map<String, String>>();
    } catch (e) {
      debugPrint('Error loading custom ringtones: $e');
      return [];
    }
  }

  /// Save custom ringtones to storage
  Future<bool> saveCustomRingtones(List<Map<String, String>> customRingtones) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String customRingtonesJson = json.encode(customRingtones);
      return await prefs.setString(AppConstants.customRingtonesKey, customRingtonesJson);
    } catch (e) {
      debugPrint('Error saving custom ringtones: $e');
      return false;
    }
  }

  /// Get all ringtones (default + custom)
  Future<List<Map<String, String>>> getAllRingtones() async {
    final customRingtones = await getCustomRingtones();
    return [...defaultRingtones, ...customRingtones];
  }

  /// Import a custom ringtone from device
  Future<String?> importCustomRingtone() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Get application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final customSoundsDir = Directory('${directory.path}/custom_sounds');
        
        // Create directory if it doesn't exist
        if (!await customSoundsDir.exists()) {
          await customSoundsDir.create(recursive: true);
        }
        
        // Copy file to app directory
        final newFile = await file.copy('${customSoundsDir.path}/$fileName');
        
        // Add to custom ringtones list
        final customRingtones = await getCustomRingtones();
        final newRingtone = {
          'name': _getDisplayName(fileName),
          'path': newFile.path,
          'type': 'custom',
        };
        
        customRingtones.add(newRingtone);
        await saveCustomRingtones(customRingtones);
        
        return newFile.path;
      }
    } catch (e) {
      debugPrint('Error importing custom ringtone: $e');
    }
    return null;
  }

  /// Delete a custom ringtone
  Future<bool> deleteCustomRingtone(String ringtonePath) async {
    try {
      final customRingtones = await getCustomRingtones();
      customRingtones.removeWhere((ringtone) => ringtone['path'] == ringtonePath);
      
      // Delete physical file
      final file = File(ringtonePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      return await saveCustomRingtones(customRingtones);
    } catch (e) {
      debugPrint('Error deleting custom ringtone: $e');
      return false;
    }
  }

  /// Get display name from filename
  String _getDisplayName(String fileName) {
    final nameWithoutExtension = fileName.split('.').first;
    return nameWithoutExtension
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Get display name for a sound by its path
  String getSoundDisplayName(String soundPath) {
    if (soundPath.isEmpty) return 'Alarm Clock'; // Default to first ringtone
    
    // Check default ringtones
    final defaultRingtone = defaultRingtones.firstWhere(
      (ringtone) => ringtone['path'] == soundPath,
      orElse: () => <String, String>{},
    );
    
    if (defaultRingtone.isNotEmpty) {
      return defaultRingtone['name']!;
    }
    
    // For custom ringtones, extract name from filename
    final fileName = soundPath.split('/').last;
    return _getDisplayName(fileName);
  }
}
