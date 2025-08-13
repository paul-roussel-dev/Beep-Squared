import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';
import '../main.dart';

/// Settings screen for configuring app preferences
/// Including adaptive theme timing configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _eveningStartHour;
  late int _eveningEndHour;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _eveningStartHour =
            prefs.getInt('evening_start_hour') ?? AppTheme.eveningStartHour;
        _eveningEndHour =
            prefs.getInt('evening_end_hour') ?? AppTheme.eveningEndHour;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        _eveningStartHour = AppTheme.eveningStartHour;
        _eveningEndHour = AppTheme.eveningEndHour;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('evening_start_hour', _eveningStartHour);
      await prefs.setInt('evening_end_hour', _eveningEndHour);

      // Invalidate theme manager cache and trigger theme reload
      ThemeManager.instance.invalidateTimeCache();
      BeepSquaredApp.reloadTheme();

      if (mounted) {
        // Pop back to home screen and trigger a rebuild
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate settings changed

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved - Theme updated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving settings'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          // Theme Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppTheme.isEveningTime ? Icons.bedtime : Icons.wb_sunny,
                        color: const Color(0xFFFFFFFF),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'Adaptive Theme',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Configure automatic color change schedule',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Evening Start Hour
                  ListTile(
                    leading: const Icon(Icons.nightlight),
                    title: const Text('Evening mode start'),
                    subtitle: Text(
                      'Switch to orange theme at ${_formatHour(_eveningStartHour)}',
                    ),
                    trailing: DropdownButton<int>(
                      value: _eveningStartHour,
                      items: List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(_formatHour(index)),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _eveningStartHour = value;
                          });
                        }
                      },
                    ),
                  ),

                  const Divider(),

                  // Evening End Hour
                  ListTile(
                    leading: const Icon(Icons.wb_sunny),
                    title: const Text('Evening mode end'),
                    subtitle: Text(
                      'Switch to blue theme at ${_formatHour(_eveningEndHour)}',
                    ),
                    trailing: DropdownButton<int>(
                      value: _eveningEndHour,
                      items: List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(_formatHour(index)),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _eveningEndHour = value;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Preview current mode
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          AppTheme.isEveningTimeCustom(
                                _eveningStartHour,
                                _eveningEndHour,
                              )
                              ? Icons.bedtime
                              : Icons.wb_sunny,
                          size: 32,
                          color: const Color(0xFFFFFFFF),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text(
                          AppTheme.isEveningTimeCustom(
                                _eveningStartHour,
                                _eveningEndHour,
                              )
                              ? 'Mode Nuit Actif'
                              : 'Mode Jour Actif',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFFFFF),
                              ),
                        ),
                        Text(
                          'Based on current time: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFFFFFFFF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingLarge),

          const SizedBox(height: AppConstants.spacingLarge),

          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFFFFFFF)),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    '🌙 The orange/warm evening theme promotes melatonin production and improves sleep quality',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    '☀️ The blue day theme stimulates alertness and energy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
