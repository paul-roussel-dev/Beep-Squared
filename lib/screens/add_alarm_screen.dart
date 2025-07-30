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
  AlarmUnlockMethod _unlockMethod = AlarmUnlockMethod.simple;
  MathDifficulty _mathDifficulty = MathDifficulty.easy;
  MathOperations _mathOperations = MathOperations.mixed;
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
      _selectedTime = TimeOfDay(
        hour: alarm.time.hour,
        minute: alarm.time.minute,
      );
      _labelController = TextEditingController(text: alarm.label);
      _isEnabled = alarm.isEnabled;
      _selectedWeekDays.addAll(alarm.weekDays);
      _vibrate = alarm.vibrate;
      _snoozeMinutes = alarm.snoozeMinutes;
      _selectedSoundPath = alarm.soundPath;
      _unlockMethod = alarm.unlockMethod;
      _mathDifficulty = alarm.mathDifficulty;
      _mathOperations = alarm.mathOperations;
    } else {
      // Initialize with default values
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController(
        text: AppConstants.defaultAlarmLabel,
      );
      _isEnabled = true;
    }

    _loadRingtones();
  }

  Future<void> _loadRingtones() async {
    final ringtones = await RingtoneService.instance.getAllRingtones();
    setState(() {
      _availableRingtones = ringtones;
      // Set default to first ringtone (Alarm Clock) only if not in edit mode and no sound selected
      if (!_isEditMode &&
          _availableRingtones.isNotEmpty &&
          _selectedSoundPath.isEmpty) {
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
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
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
      final currentTime = TimeOfDay(
        hour: original.time.hour,
        minute: original.time.minute,
      );

      return _selectedTime != currentTime ||
          _labelController.text != original.label ||
          !_compareLists(_selectedWeekDays, original.weekDays) ||
          _vibrate != original.vibrate ||
          _snoozeMinutes != original.snoozeMinutes ||
          _selectedSoundPath != original.soundPath ||
          _unlockMethod != original.unlockMethod ||
          _mathDifficulty != original.mathDifficulty ||
          _mathOperations != original.mathOperations ||
          _isEnabled != original.isEnabled;
    } else {
      // Check against default values for new alarm
      return _labelController.text != AppConstants.defaultAlarmLabel ||
          _selectedWeekDays.isNotEmpty ||
          !_vibrate ||
          _snoozeMinutes != AppConstants.defaultSnoozeMinutes ||
          _selectedSoundPath.isNotEmpty ||
          _unlockMethod != AlarmUnlockMethod.simple ||
          _mathDifficulty != MathDifficulty.easy ||
          _mathOperations != MathOperations.mixed;
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Alarm' : 'Add Alarm',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            FilledButton(
              onPressed: _saveAlarm,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: Text(_isEditMode ? 'Update' : 'Save'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Picker Section
              _buildTimeSection(),
              const SizedBox(height: 24),

              // Label Section
              _buildLabelSection(),
              const SizedBox(height: 24),

              // Repeat Section
              _buildRepeatSection(),
              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build time selection section
  Widget _buildTimeSection() {
    return Card(
      child: InkWell(
        onTap: _selectTime,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alarm Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(_selectedTime),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build label input section
  Widget _buildLabelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.label,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Alarm Label',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: 'Enter alarm name',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Build repeat options section
  Widget _buildRepeatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.repeat,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPresetSelector(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Custom Days',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeekDaySelector(),
          ],
        ),
      ),
    );
  }

  /// Build settings section
  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        children: [
          // Sound Selection
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Ringtone'),
            subtitle: Text(
              _getSoundDisplayName(_selectedSoundPath),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: _selectSound,
          ),
          const Divider(height: 1),
          // Vibration Setting
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.vibration,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Vibrate'),
            subtitle: Text(
              _vibrate ? 'Device will vibrate' : 'Silent vibration',
            ),
            value: _vibrate,
            onChanged: (value) {
              setState(() {
                _vibrate = value;
              });
            },
          ),
          const Divider(height: 1),
          // Snooze Setting
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.snooze,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                size: 20,
              ),
            ),
            title: const Text('Snooze Duration'),
            subtitle: Text(
              '$_snoozeMinutes minutes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: _selectSnoozeTime,
          ),
          const Divider(height: 1),
          // Unlock Method Setting
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_open,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 20,
              ),
            ),
            title: const Text('Unlock Method'),
            subtitle: Text(
              _unlockMethod.displayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: _selectUnlockMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    // Check current selection against presets
    final isWeekdaySelected =
        _selectedWeekDays.length == 5 &&
        _selectedWeekDays.every((day) => day >= 0 && day <= 4);
    final isWeekendSelected =
        _selectedWeekDays.length == 2 &&
        _selectedWeekDays.contains(5) &&
        _selectedWeekDays.contains(6);
    final isAllSelected = _selectedWeekDays.length == 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Weekday'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('weekday'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Weekend'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('weekend'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Daily'),
                    )
                  : OutlinedButton(
                      onPressed: () => _selectPreset('all'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Daily'),
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
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedWeekDays.contains(index);
        return FilterChip(
          label: Text(
            weekDays[index],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          selected: isSelected,
          selectedColor: Theme.of(context).colorScheme.secondaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
      helpText: 'Select alarm time',
      cancelText: 'Cancel',
      confirmText: 'Set Time',
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
      builder: (context) => AlertDialog(
        title: const Text('Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: snoozeOptions
              .map(
                (minutes) => ListTile(
                  title: Text('$minutes minutes'),
                  trailing: _snoozeMinutes == minutes
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _snoozeMinutes = minutes;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectUnlockMethod() async {
    final selectedMethod = await showDialog<AlarmUnlockMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Méthode de Déverrouillage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AlarmUnlockMethod.values
              .map(
                (method) => ListTile(
                  leading: Icon(
                    _getUnlockMethodIcon(method),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(method.displayName),
                  subtitle: Text(
                    method.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: _unlockMethod == method
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context, method);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedMethod != null) {
      setState(() {
        _unlockMethod = selectedMethod;
      });

      // Si math est sélectionné, montrer les options de personnalisation
      if (selectedMethod == AlarmUnlockMethod.math) {
        await _configureMathSettings();
      }
    }
  }

  Future<void> _configureMathSettings() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuration Calcul'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulté avec boutons compacts
                const Text(
                  'Difficulté:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MathDifficulty.values.map((difficulty) {
                    final isSelected = _mathDifficulty == difficulty;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ElevatedButton(
                          onPressed: () {
                            setDialogState(() {
                              _mathDifficulty = difficulty;
                            });
                            setState(() {
                              _mathDifficulty = difficulty;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            foregroundColor: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            difficulty.displayName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Opérations avec boutons icônes
                const Text(
                  'Opérations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Addition
                    _buildOperationButton(
                      context,
                      setDialogState,
                      MathOperations.additionOnly,
                      '+',
                      _mathOperations == MathOperations.additionOnly,
                    ),
                    // Soustraction
                    _buildOperationButton(
                      context,
                      setDialogState,
                      MathOperations.subtractionOnly,
                      '−',
                      _mathOperations == MathOperations.subtractionOnly,
                    ),
                    // Multiplication
                    _buildOperationButton(
                      context,
                      setDialogState,
                      MathOperations.multiplicationOnly,
                      '×',
                      _mathOperations == MathOperations.multiplicationOnly,
                    ),
                    // Mélangé
                    _buildOperationButton(
                      context,
                      setDialogState,
                      MathOperations.mixed,
                      '±×',
                      _mathOperations == MathOperations.mixed,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Exemple du calcul actuel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Exemple:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getExampleProblem(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButton(
    BuildContext context,
    StateSetter setDialogState,
    MathOperations operation,
    String symbol,
    bool isSelected,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () {
            setDialogState(() {
              _mathOperations = operation;
            });
            setState(() {
              _mathOperations = operation;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            foregroundColor: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _getExampleProblem() {
    switch (_mathOperations) {
      case MathOperations.additionOnly:
        return _mathDifficulty == MathDifficulty.easy
            ? '23 + 17 = ?'
            : _mathDifficulty == MathDifficulty.medium
            ? '67 + 84 = ?'
            : '156 + 127 = ?';
      case MathOperations.subtractionOnly:
        return _mathDifficulty == MathDifficulty.easy
            ? '45 - 12 = ?'
            : _mathDifficulty == MathDifficulty.medium
            ? '89 - 34 = ?'
            : '178 - 89 = ?';
      case MathOperations.multiplicationOnly:
        return _mathDifficulty == MathDifficulty.easy
            ? '7 × 6 = ?'
            : _mathDifficulty == MathDifficulty.medium
            ? '11 × 12 = ?'
            : '14 × 15 = ?';
      case MathOperations.mixed:
        return _mathDifficulty == MathDifficulty.easy
            ? '12 + 8 = ?'
            : _mathDifficulty == MathDifficulty.medium
            ? '9 × 7 = ?'
            : '145 - 78 = ?';
    }
  }

  IconData _getUnlockMethodIcon(AlarmUnlockMethod method) {
    switch (method) {
      case AlarmUnlockMethod.simple:
        return Icons.touch_app;
      case AlarmUnlockMethod.math:
        return Icons.calculate;
    }
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
      final importedPath = await RingtoneService.instance
          .importCustomRingtone();
      if (importedPath != null) {
        setState(() {
          _selectedSoundPath = importedPath;
        });
        await _loadRingtones(); // Recharger la liste

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Custom ringtone imported successfully!'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing ringtone: $e')));
      }
    }
  }

  Future<void> _deleteCustomRingtone(String ringtonePath) async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ringtone'),
        content: const Text(
          'Are you sure you want to delete this custom ringtone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pop(context); // Fermer le dialogue de sélection

      final success = await RingtoneService.instance.deleteCustomRingtone(
        ringtonePath,
      );
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
            const SnackBar(
              content: Text('Custom ringtone deleted successfully!'),
            ),
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
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _saveAlarm() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an alarm label')),
      );
      return;
    }

    // Create alarm
    final now = DateTime.now();
    final alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final alarm = Alarm(
      id: _isEditMode
          ? widget.alarm!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      time: alarmDateTime,
      label: _labelController.text.trim(),
      isEnabled: _isEnabled,
      weekDays: List.from(_selectedWeekDays),
      vibrate: _vibrate,
      snoozeMinutes: _snoozeMinutes,
      soundPath: _selectedSoundPath,
      unlockMethod: _unlockMethod,
      mathDifficulty: _mathDifficulty,
      mathOperations: _mathOperations,
    );

    Navigator.pop(context, alarm);
  }
}

/// Dialog for selecting ringtones
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
  State<_RingtoneSelectionDialog> createState() =>
      _RingtoneSelectionDialogState();
}

class _RingtoneSelectionDialogState extends State<_RingtoneSelectionDialog> {
  final AudioPreviewService _audioPreviewService = AudioPreviewService.instance;

  @override
  void dispose() {
    _audioPreviewService.stopPreview();
    super.dispose();
  }

  void _togglePreview(String soundPath) async {
    if (_audioPreviewService.isPlaying) {
      _audioPreviewService.stopPreview();
    } else {
      await _audioPreviewService.playPreview(soundPath);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Ringtone'),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableRingtones.length,
                itemBuilder: (context, index) {
                  final sound = widget.availableRingtones[index];
                  final soundPath = sound['path'] ?? '';
                  final displayName = sound['name'] ?? 'Unknown';
                  final isSelected = soundPath == widget.selectedSoundPath;
                  final isPreviewing = _audioPreviewService.isPlaying;

                  return ListTile(
                    leading: Radio<String>(
                      value: soundPath,
                      groupValue: widget.selectedSoundPath,
                      onChanged: (value) {
                        if (value != null) {
                          _audioPreviewService.stopPreview();
                          Navigator.pop(context, value);
                        }
                      },
                    ),
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: sound['type'] == 'custom'
                        ? Text(
                            'Custom',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton de prévisualisation
                        IconButton(
                          icon: Icon(
                            isPreviewing ? Icons.stop : Icons.play_arrow,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          onPressed: () => _togglePreview(soundPath),
                          tooltip: isPreviewing ? 'Stop' : 'Play',
                        ),
                        // Bouton de suppression pour les sonneries personnalisées
                        if (sound['type'] == 'custom')
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () =>
                                widget.onDeleteCustomRingtone(soundPath),
                            tooltip: 'Delete',
                          ),
                      ],
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
              title: const Text(
                'Import Custom Ringtone',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
