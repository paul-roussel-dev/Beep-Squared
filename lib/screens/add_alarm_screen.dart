import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm.dart';
import '../utils/constants.dart';
import '../services/ringtone_service.dart';
import '../services/audio_preview_service.dart';

class AddAlarmScreen extends StatefulWidget {
  final Alarm? alarm; // Alarme existante à éditer (optionnel)
  
  const AddAlarmScreen({super.key, this.alarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late bool _isEnabled;
  final List<int> _selectedWeekDays = [];
  bool _vibrate = true;
  int _snoozeMinutes = AppConstants.defaultSnoozeMinutes;
  String _selectedSoundPath = '';
  List<Map<String, String>> _availableRingtones = [];
  
  final AudioPreviewService _audioPreviewService = AudioPreviewService.instance;

  /// Check if we're in edit mode
  bool get _isEditMode => widget.alarm != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditMode) {
      // Initialize with existing alarm data
      final alarm = widget.alarm!;
      _selectedTime = TimeOfDay(hour: alarm.time.hour, minute: alarm.time.minute);
      _labelController = TextEditingController(text: alarm.label);
      _isEnabled = alarm.isEnabled;
      _selectedWeekDays.addAll(alarm.weekDays);
      _vibrate = alarm.vibrate;
      _snoozeMinutes = alarm.snoozeMinutes;
      _selectedSoundPath = alarm.soundPath;
    } else {
      // Initialize with default values
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController(text: AppConstants.defaultAlarmLabel);
      _isEnabled = true;
    }
    
    _loadRingtones();
  }

  Future<void> _loadRingtones() async {
    final ringtones = await RingtoneService.instance.getAllRingtones();
    setState(() {
      _availableRingtones = ringtones;
      // Set default to first ringtone (Alarm Clock) only if not in edit mode and no sound selected
      if (!_isEditMode && _availableRingtones.isNotEmpty && _selectedSoundPath.isEmpty) {
        _selectedSoundPath = _availableRingtones.first['path'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _audioPreviewService.stopPreview(); // Arrêter tout son en cours
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Vérifier si des changements ont été faits
    if (_hasChanges()) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to leave?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  bool _hasChanges() {
    if (_isEditMode) {
      // Compare with original alarm values
      final original = widget.alarm!;
      final currentTime = TimeOfDay(hour: original.time.hour, minute: original.time.minute);
      
      return _selectedTime != currentTime ||
             _labelController.text != original.label ||
             !_compareLists(_selectedWeekDays, original.weekDays) ||
             _vibrate != original.vibrate ||
             _snoozeMinutes != original.snoozeMinutes ||
             _selectedSoundPath != original.soundPath ||
             _isEnabled != original.isEnabled;
    } else {
      // Check against default values for new alarm
      return _labelController.text != AppConstants.defaultAlarmLabel ||
             _selectedWeekDays.isNotEmpty ||
             !_vibrate ||
             _snoozeMinutes != AppConstants.defaultSnoozeMinutes ||
             _selectedSoundPath.isNotEmpty;
    }
  }

  /// Helper method to compare two lists
  bool _compareLists(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Alarm' : 'Add Alarm'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            TextButton(
              onPressed: _saveAlarm,
              child: Text(
                _isEditMode ? 'Update' : 'Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_formatTime(_selectedTime)),
                onTap: _selectTime,
              ),
            ),
            const SizedBox(height: 16),

            // Label Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Label',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'Enter alarm label',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Repeat Days
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Repeat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildPresetSelector(),
                      const SizedBox(height: 16),
                      Text(
                        'Custom Days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeekDaySelector(),
                    ],
                  ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings
            Card(
              child: Column(
                children: [
                  // Sound Selection
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('Ringtone'),
                    subtitle: Text(_getSoundDisplayName(_selectedSoundPath)),
                    onTap: _selectSound,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration),
                    title: const Text('Vibrate'),
                    value: _vibrate,
                    onChanged: (value) {
                      setState(() {
                        _vibrate = value;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.snooze),
                    title: const Text('Snooze'),
                    subtitle: Text('$_snoozeMinutes minutes'),
                    onTap: _selectSnoozeTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    // Check current selection against presets
    final isWeekdaySelected = _selectedWeekDays.length == 5 && 
        _selectedWeekDays.every((day) => day >= 0 && day <= 4);
    final isWeekendSelected = _selectedWeekDays.length == 2 && 
        _selectedWeekDays.contains(5) && _selectedWeekDays.contains(6);
    final isAllSelected = _selectedWeekDays.length == 7;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: isWeekdaySelected
                  ? FilledButton(
                      onPressed: () => _selectPreset('weekday'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Weekday'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('weekday'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Weekday'),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isWeekendSelected
                  ? FilledButton(
                      onPressed: () => _selectPreset('weekend'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Weekend'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('weekend'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Weekend'),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isAllSelected
                  ? FilledButton(
                      onPressed: () => _selectPreset('all'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('All'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('all'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('All'),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectPreset(String preset) {
    setState(() {
      _selectedWeekDays.clear();
      switch (preset) {
        case 'weekday':
          // Monday to Friday (0-4)
          _selectedWeekDays.addAll([0, 1, 2, 3, 4]);
          break;
        case 'weekend':
          // Saturday and Sunday (5-6)
          _selectedWeekDays.addAll([5, 6]);
          break;
        case 'all':
          // All days (0-6)
          _selectedWeekDays.addAll([0, 1, 2, 3, 4, 5, 6]);
          break;
      }
    });
  }

  Widget _buildWeekDaySelector() {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedWeekDays.contains(index);
        return FilterChip(
          label: Text(weekDays[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedWeekDays.add(index);
              } else {
                _selectedWeekDays.remove(index);
              }
            });
          },
        );
      }),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectSnoozeTime() async {
    final List<int> snoozeOptions = [1, 5, 10, 15, 30];
    
    await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Snooze Duration'),
        children: snoozeOptions.map((minutes) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              _snoozeMinutes = minutes;
            });
            Navigator.pop(context);
          },
          child: Text('$minutes minutes'),
        )).toList(),
      ),
    );
  }

  Future<void> _selectSound() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _RingtoneSelectionDialog(
        availableRingtones: _availableRingtones,
        selectedSoundPath: _selectedSoundPath,
        onDeleteCustomRingtone: _deleteCustomRingtone,
      ),
    );

    if (result != null) {
      if (result == 'IMPORT_CUSTOM') {
        await _importCustomRingtone();
      } else {
        setState(() {
          _selectedSoundPath = result;
        });
      }
    }
  }

  Future<void> _importCustomRingtone() async {
    try {
      final importedPath = await RingtoneService.instance.importCustomRingtone();
      if (importedPath != null) {
        setState(() {
          _selectedSoundPath = importedPath;
        });
        await _loadRingtones(); // Recharger la liste
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom ringtone imported successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing ringtone: $e')),
        );
      }
    }
  }

  Future<void> _deleteCustomRingtone(String ringtonePath) async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ringtone'),
        content: const Text('Are you sure you want to delete this custom ringtone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pop(context); // Fermer le dialogue de sélection
      
      final success = await RingtoneService.instance.deleteCustomRingtone(ringtonePath);
      if (success) {
        if (_selectedSoundPath == ringtonePath) {
          setState(() {
            // Revenir au premier ringtone (Alarm Clock)
            _selectedSoundPath = _availableRingtones.isNotEmpty 
                ? _availableRingtones.first['path'] ?? ''
                : '';
          });
        }
        await _loadRingtones(); // Recharger la liste
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom ringtone deleted successfully!')),
          );
        }
      }
    }
  }

  String _getSoundDisplayName(String soundPath) {
    return RingtoneService.instance.getSoundDisplayName(soundPath);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime);
  }

  void _saveAlarm() {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final alarm = Alarm(
      id: _isEditMode ? widget.alarm!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.isEmpty 
          ? AppConstants.defaultAlarmLabel 
          : _labelController.text,
      time: alarmTime,
      isEnabled: _isEnabled,
      weekDays: _selectedWeekDays,
      soundPath: _selectedSoundPath,
      snoozeMinutes: _snoozeMinutes,
      vibrate: _vibrate,
    );

    Navigator.pop(context, alarm);
  }
}

// Widget de dialogue personnalisé pour la sélection de sonnerie avec prévisualisation
class _RingtoneSelectionDialog extends StatefulWidget {
  final List<Map<String, String>> availableRingtones;
  final String selectedSoundPath;
  final Function(String) onDeleteCustomRingtone;

  const _RingtoneSelectionDialog({
    required this.availableRingtones,
    required this.selectedSoundPath,
    required this.onDeleteCustomRingtone,
  });

  @override
  State<_RingtoneSelectionDialog> createState() => _RingtoneSelectionDialogState();
}

class _RingtoneSelectionDialogState extends State<_RingtoneSelectionDialog> {
  final AudioPreviewService _audioPreviewService = AudioPreviewService.instance;
  String? _currentlyPreviewing;

  @override
  void dispose() {
    _audioPreviewService.stopPreview();
    super.dispose();
  }

  Future<void> _togglePreview(String soundPath) async {
    if (_currentlyPreviewing == soundPath) {
      // Arrêter la prévisualisation
      await _audioPreviewService.stopPreview();
      setState(() {
        _currentlyPreviewing = null;
      });
    } else {
      // Jouer la prévisualisation
      await _audioPreviewService.playPreview(soundPath);
      setState(() {
        _currentlyPreviewing = soundPath;
      });
      
      // Arrêter automatiquement après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _currentlyPreviewing == soundPath) {
          setState(() {
            _currentlyPreviewing = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Ringtone'),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // 90% de la largeur de l'écran
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: widget.availableRingtones.length,
                itemBuilder: (context, index) {
                  final sound = widget.availableRingtones[index];
                  final soundPath = sound['path']!;
                  final isSelected = widget.selectedSoundPath == soundPath;
                  final isPreviewing = _currentlyPreviewing == soundPath;
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      sound['name']!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: isPreviewing 
                        ? const Text('♪ Playing...', style: TextStyle(color: Colors.green)) 
                        : null,
                    trailing: SizedBox(
                      width: sound['type'] == 'custom' ? 96 : 48, // Largeur fixe pour éviter l'overflow
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton de prévisualisation (plus petit)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isPreviewing ? Icons.stop : Icons.play_arrow,
                                color: isPreviewing ? Colors.red : Colors.green,
                                size: 20,
                              ),
                              onPressed: () => _togglePreview(soundPath),
                              tooltip: isPreviewing ? 'Stop' : 'Play',
                            ),
                          ),
                          // Bouton de suppression pour les sonneries personnalisées (plus petit)
                          if (sound['type'] == 'custom')
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                onPressed: () => widget.onDeleteCustomRingtone(soundPath),
                                tooltip: 'Delete',
                              ),
                            ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _audioPreviewService.stopPreview();
                      Navigator.pop(context, soundPath);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.green),
              title: const Text('Import Custom Ringtone', style: TextStyle(color: Colors.green)),
              onTap: () {
                _audioPreviewService.stopPreview();
                Navigator.pop(context, 'IMPORT_CUSTOM');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _audioPreviewService.stopPreview();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
