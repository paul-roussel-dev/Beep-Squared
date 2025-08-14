import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/alarm_manager_service.dart';
import '../widgets/alarm_card.dart';
import '../constants/constants.dart';
import 'add_alarm_screen.dart';
import 'settings_screen.dart';

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
    try {
      // Set context for alarm manager
      _managerService.setContext(context);

      // Initialize alarm manager
      await _managerService.initialize();
      debugPrint('Alarm services initialized successfully');
    } catch (e) {
      debugPrint('Error initializing alarm services: $e');
      // In release builds, some initialization may fail due to obfuscation
      // but we should continue with basic functionality
      if (kReleaseMode) {
        debugPrint(
          'Release mode: Continuing despite service initialization errors',
        );
        // Show a warning to user but don't crash
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.alarmServiceLimitedMessage),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // In debug mode, we want to see the full error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.alarmInitializationError}: $e'),
              duration: const Duration(seconds: 8),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }
    }
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
        title: const Text(AppStrings.exitApp),
        content: Text(AppStrings.exitAppConfirm(AppStrings.appName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.exit),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  /// Navigate to settings screen
  Future<void> _navigateToSettings() async {
    final settingsChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    // If settings changed, trigger a complete rebuild
    if (mounted && settingsChanged == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _onWillPop();
          if (shouldExit && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          leading: _buildThemeModeIndicator(), // Theme indicator
          actions: [
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _navigateToSettings(),
              tooltip: AppStrings.settings,
            ),
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
                        Icon(
                          Icons.clear_all,
                          color: AppColors.white,
                          size: AppSizes.iconMedium,
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        Text(
                          AppStrings.clearAll,
                          style: TextStyle(
                            color: AppColors.white,
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
                    const CircularProgressIndicator(color: AppColors.white),
                    const SizedBox(height: AppSizes.spacingMedium),
                    Text(
                      AppStrings.loadingAlarms,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              )
            : _alarms.isEmpty
            ? _buildEmptyState()
            : _buildAlarmsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: _addAlarm,
          tooltip: AppStrings.addAlarm,
          elevation: 6,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              padding: AppSizes.paddingAllLarge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alarm,
                size: AppSizes.iconXxl,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXl),
            Text(
              AppStrings.noAlarmsMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              AppStrings.createFirstAlarm,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),
            FilledButton.icon(
              onPressed: _addAlarm,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addYourFirstAlarm),
              style: FilledButton.styleFrom(padding: AppSizes.paddingButton),
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
          padding: AppSizes.paddingAll,
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: AppSizes.iconMedium,
                  color: AppColors.white,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  AppStrings.alarmCount(_alarms.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
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
              padding: AppSizes.marginCard,
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
          child: SizedBox(height: AppSizes.fabSpacing), // Space for FAB
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
            content: Text(AppStrings.alarmSetFor(result.formattedTime)),
            backgroundColor: AppColors.notificationSuccess,
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
            content: Text(AppStrings.alarmUpdatedFor(result.formattedTime)),
            backgroundColor: AppColors.notificationSuccess,
          ),
        );
      }
    }
  }

  Future<void> _toggleAlarm(Alarm alarm) async {
    // Toggle alarm state
    await _alarmService.toggleAlarm(alarm.id);

    // Get the updated alarm to check its new state
    final alarms = await _alarmService.getAlarms();
    final updatedAlarm = alarms.firstWhere((a) => a.id == alarm.id);

    // Update alarm scheduling based on new state
    if (updatedAlarm.isEnabled) {
      // Alarm is now enabled - schedule notification
      await _schedulerService.scheduleAlarm(updatedAlarm);
    } else {
      // Alarm is now disabled - cancel notification
      await _schedulerService.cancelAlarm(alarm.id);
    }

    await _loadAlarms();
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteAlarm),
        content: Text(AppStrings.deleteAlarmConfirm(alarm.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            child: const Text(AppStrings.delete),
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
          const SnackBar(
            content: Text(AppStrings.alarmDeleted),
            backgroundColor: AppColors.notificationSuccess,
          ),
        );
      }
    }
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearAllAlarms),
        content: const Text(AppStrings.clearAllAlarmsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            child: const Text(AppStrings.clearAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _alarmService.clearAllAlarms();
      await _loadAlarms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.allAlarmsCleared),
            backgroundColor: AppColors.notificationSuccess,
          ),
        );
      }
    }
  }

  /// Build theme mode indicator showing day/evening status
  Widget _buildThemeModeIndicator() {
    final isCurrentlyEvening = ThemeManager.instance.effectiveIsEveningTime;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isCurrentlyEvening ? Icons.bedtime : Icons.wb_sunny,
        size: 20,
        color: AppColors.white,
      ),
    );
  }
}
