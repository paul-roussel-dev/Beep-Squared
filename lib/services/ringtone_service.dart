import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RingtoneService {
  static const String _customRingtonesKey = 'custom_ringtones';
  static RingtoneService? _instance;
  
  RingtoneService._();
  
  static RingtoneService get instance {
    _instance ??= RingtoneService._();
    return _instance!;
  }

  // Sonneries par défaut (assets)
  List<Map<String, String>> get defaultRingtones => [
    {'name': 'Default', 'path': '', 'type': 'system'},
    {'name': 'Alarm Clock', 'path': 'assets/sounds/alarm-clock-short-6402.mp3', 'type': 'asset'},
    {'name': 'Bright Electronic', 'path': 'assets/sounds/bright-electronic-loop-251871.mp3', 'type': 'asset'},
    {'name': 'Level Up', 'path': 'assets/sounds/level-up-06-370051.mp3', 'type': 'asset'},
    {'name': 'Melody Ring', 'path': 'assets/sounds/melody-ring-tone-313022.mp3', 'type': 'asset'},
    {'name': 'Original Phone', 'path': 'assets/sounds/original-phone-ringtone-36558.mp3', 'type': 'asset'},
    {'name': 'Ringtone', 'path': 'assets/sounds/ringtone-249206.mp3', 'type': 'asset'},
    {'name': 'Soft Ring', 'path': 'assets/sounds/soft-ring-tone-313009.mp3', 'type': 'asset'},
  ];

  // Récupérer les sonneries personnalisées
  Future<List<Map<String, String>>> getCustomRingtones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customRingtonesJson = prefs.getString(_customRingtonesKey);
      
      if (customRingtonesJson == null) return [];
      
      final List<dynamic> customRingtonesList = json.decode(customRingtonesJson);
      return customRingtonesList.cast<Map<String, String>>();
    } catch (e) {
      print('Error loading custom ringtones: $e');
      return [];
    }
  }

  // Sauvegarder les sonneries personnalisées
  Future<bool> saveCustomRingtones(List<Map<String, String>> customRingtones) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String customRingtonesJson = json.encode(customRingtones);
      return await prefs.setString(_customRingtonesKey, customRingtonesJson);
    } catch (e) {
      print('Error saving custom ringtones: $e');
      return false;
    }
  }

  // Récupérer toutes les sonneries (défaut + personnalisées)
  Future<List<Map<String, String>>> getAllRingtones() async {
    final customRingtones = await getCustomRingtones();
    return [...defaultRingtones, ...customRingtones];
  }

  // Importer une sonnerie personnalisée
  Future<String?> importCustomRingtone() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Obtenir le répertoire des documents de l'app
        final directory = await getApplicationDocumentsDirectory();
        final customSoundsDir = Directory('${directory.path}/custom_sounds');
        
        // Créer le dossier s'il n'existe pas
        if (!await customSoundsDir.exists()) {
          await customSoundsDir.create(recursive: true);
        }
        
        // Copier le fichier dans le dossier de l'app
        final newFile = await file.copy('${customSoundsDir.path}/$fileName');
        
        // Ajouter à la liste des sonneries personnalisées
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
      print('Error importing custom ringtone: $e');
    }
    return null;
  }

  // Supprimer une sonnerie personnalisée
  Future<bool> deleteCustomRingtone(String ringtonePath) async {
    try {
      final customRingtones = await getCustomRingtones();
      customRingtones.removeWhere((ringtone) => ringtone['path'] == ringtonePath);
      
      // Supprimer le fichier physique
      final file = File(ringtonePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      return await saveCustomRingtones(customRingtones);
    } catch (e) {
      print('Error deleting custom ringtone: $e');
      return false;
    }
  }

  // Obtenir le nom d'affichage à partir du nom de fichier
  String _getDisplayName(String fileName) {
    final nameWithoutExtension = fileName.split('.').first;
    return nameWithoutExtension
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Obtenir le nom d'affichage d'une sonnerie par son chemin
  String getSoundDisplayName(String soundPath) {
    if (soundPath.isEmpty) return 'Default';
    
    // Vérifier les sonneries par défaut
    final defaultRingtone = defaultRingtones.firstWhere(
      (ringtone) => ringtone['path'] == soundPath,
      orElse: () => <String, String>{},
    );
    
    if (defaultRingtone.isNotEmpty) {
      return defaultRingtone['name']!;
    }
    
    // Pour les sonneries personnalisées, extraire le nom du fichier
    final fileName = soundPath.split('/').last;
    return _getDisplayName(fileName);
  }
}
