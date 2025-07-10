import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../widgets/alarm_card.dart';
import 'add_alarm_screen.dart';

/// Home screen displaying the list of alarms
/// 
/// This screen shows all user alarms with options to add, edit, delete,
/// and toggle alarms. It handles the main navigation and provides access
/// to alarm management functionality.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlarmService _alarmService = AlarmService.instance;
  List<Alarm> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  /// Load alarms from storage
  Future<void> _loadAlarms() async {
    setState(() {
      _isLoading = true;
    });
    
    final alarms = await _alarmService.getAlarms();
    
    setState(() {
      _alarms = alarms;
      _isLoading = false;
    });
  }

  /// Handle back button press with confirmation
  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit ${AppConstants.appName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          centerTitle: true,
          actions: [
          if (_alarms.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
              ? _buildEmptyState()
              : _buildAlarmsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        tooltip: AppConstants.addAlarmTooltip,
        child: const Icon(Icons.add),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.alarm,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            AppConstants.noAlarmsMessage,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to add your first alarm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList() {
    // Sort alarms by time
    final sortedAlarms = List<Alarm>.from(_alarms)
      ..sort((a, b) {
        final timeA = a.time.hour * 60 + a.time.minute;
        final timeB = b.time.hour * 60 + b.time.minute;
        return timeA.compareTo(timeB);
      });

    return ListView.builder(
      itemCount: sortedAlarms.length,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemBuilder: (context, index) {
        final alarm = sortedAlarms[index];
        return AlarmCard(
          alarm: alarm,
          onToggle: () => _toggleAlarm(alarm),
          onDelete: () => _deleteAlarm(alarm),
          onEdit: () => _editAlarm(alarm),
        );
      },
    );
  }

  Future<void> _addAlarm() async {
    final result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAlarmScreen(),
      ),
    );

    if (result != null) {
      await _alarmService.addAlarm(result);
      await _loadAlarms();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.alarmSetMessage} ${result.formattedTime}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _editAlarm(Alarm alarm) async {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  Future<void> _toggleAlarm(Alarm alarm) async {
    await _alarmService.toggleAlarm(alarm.id);
    await _loadAlarms();
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text('Are you sure you want to delete the alarm "${alarm.label}"?'),
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
      await _alarmService.deleteAlarm(alarm.id);
      await _loadAlarms();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.alarmDeletedMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Alarms'),
        content: const Text('Are you sure you want to delete all alarms?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _alarmService.clearAllAlarms();
      await _loadAlarms();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All alarms cleared'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
