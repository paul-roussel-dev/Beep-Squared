import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm.dart';
import '../utils/constants.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  final bool _isEnabled = true;
  final List<int> _selectedWeekDays = [];
  bool _vibrate = true;
  int _snoozeMinutes = AppConstants.defaultSnoozeMinutes;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
    _labelController = TextEditingController(text: AppConstants.defaultAlarmLabel);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: Text(
              'Save',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Repeat',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    );
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.isEmpty 
          ? AppConstants.defaultAlarmLabel 
          : _labelController.text,
      time: alarmTime,
      isEnabled: _isEnabled,
      weekDays: _selectedWeekDays,
      snoozeMinutes: _snoozeMinutes,
      vibrate: _vibrate,
    );

    Navigator.pop(context, alarm);
  }
}
