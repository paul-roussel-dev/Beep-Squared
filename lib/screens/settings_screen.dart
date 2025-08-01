import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
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

      // Trigger theme reload in main app
      BeepSquaredApp.reloadTheme();

      if (mounted) {
        // Pop back to home screen and trigger a rebuild
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate settings changed

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres sauvegardés - Thème mis à jour'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
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
        appBar: AppBar(title: const Text('Paramètres')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Sauvegarder',
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'Thème Adaptatif',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Configuration des horaires de changement de couleur automatique',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Evening Start Hour
                  ListTile(
                    leading: const Icon(Icons.nightlight),
                    title: const Text('Début du mode nuit'),
                    subtitle: Text(
                      'Passage au thème orange à ${_formatHour(_eveningStartHour)}',
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
                    title: const Text('Fin du mode nuit'),
                    subtitle: Text(
                      'Passage au thème bleu à ${_formatHour(_eveningEndHour)}',
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
                          color: Theme.of(context).colorScheme.primary,
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
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Basé sur l\'heure actuelle: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'À propos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    '🌙 Le thème orange/warm du soir favorise la production de mélatonine et améliore la qualité du sommeil',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    '☀️ Le thème bleu du jour stimule la vigilance et l\'énergie',
                    style: Theme.of(context).textTheme.bodyMedium,
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
