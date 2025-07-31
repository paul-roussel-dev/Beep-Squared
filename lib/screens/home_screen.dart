import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/alarm_manager_service.dart';
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
  final AlarmSchedulerService _schedulerService =
      AlarmSchedulerService.instance;
  final AlarmManagerService _managerService = AlarmManagerService.instance;
  List<Alarm> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAlarmServices();
    _loadAlarms();
  }

  /// Initialize alarm services
  Future<void> _initializeAlarmServices() async {
    // Set context for alarm manager
    _managerService.setContext(context);

    // Initialize alarm manager
    await _managerService.initialize();
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
        content: const Text(
          'Are you sure you want to exit ${AppConstants.appName}?',
        ),
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
          title: Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            if (_alarms.isNotEmpty)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllDialog();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.clear_all,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Clear all',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading alarms...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _alarms.isEmpty
            ? _buildEmptyState()
            : _buildAlarmsList(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addAlarm,
          tooltip: AppConstants.addAlarmTooltip,
          icon: const Icon(Icons.add),
          label: const Text('Add Alarm'),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.noAlarmsMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first alarm to get started.\nTap the button below to begin.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addAlarm,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Alarm'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_alarms.length} alarm${_alarms.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final alarm = sortedAlarms[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: AlarmCard(
                alarm: alarm,
                onToggle: () => _toggleAlarm(alarm),
                onDelete: () => _deleteAlarm(alarm),
                onEdit: () => _editAlarm(alarm),
              ),
            );
          }, childCount: sortedAlarms.length),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Space for FAB
        ),
      ],
    );
  }

  Future<void> _addAlarm() async {
    final result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
    );

    if (result != null) {
      // Save alarm to storage
      await _alarmService.addAlarm(result);

      // Schedule alarm notification
      if (result.isEnabled) {
        await _schedulerService.scheduleAlarm(result);
      }

      await _loadAlarms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppConstants.alarmSetMessage} ${result.formattedTime}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _editAlarm(Alarm alarm) async {
    final result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(builder: (context) => AddAlarmScreen(alarm: alarm)),
    );

    if (result != null) {
      // Update alarm in storage
      await _alarmService.updateAlarm(result);

      // Cancel old alarm notification
      await _schedulerService.cancelAlarm(alarm.id);

      // Schedule new alarm notification if enabled
      if (result.isEnabled) {
        await _schedulerService.scheduleAlarm(result);
      }

      await _loadAlarms();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppConstants.alarmUpdatedMessage} ${result.formattedTime}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _toggleAlarm(Alarm alarm) async {
    // Toggle alarm state
    await _alarmService.toggleAlarm(alarm.id);

    // Update alarm scheduling
    if (alarm.isEnabled) {
      // Alarm was enabled, now disabled - cancel notification
      await _schedulerService.cancelAlarm(alarm.id);
    } else {
      // Alarm was disabled, now enabled - schedule notification
      await _schedulerService.scheduleAlarm(alarm.copyWith(isEnabled: true));
    }

    await _loadAlarms();
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text(
          'Are you sure you want to delete the alarm "${alarm.label}"?',
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
      // Cancel alarm notification
      await _schedulerService.cancelAlarm(alarm.id);

      // Delete alarm from storage
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
