import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/ringtone_service.dart';

/// Widget displaying an alarm card with all alarm information
///
/// This widget shows alarm time, label, recurrence, ringtone, and actions.
/// It uses Material Design principles and handles overflow gracefully.
class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const AlarmCard({
    super.key,
    required this.alarm,
    this.onToggle,
    this.onDelete,
    this.onEdit,
  });

  /// Get display name for the alarm sound
  String _getSoundDisplayName(String soundPath) {
    return RingtoneService.instance.getSoundDisplayName(soundPath);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: alarm.isEnabled ? 2 : 1,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Time and status
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          alarm.formattedTime,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: alarm.isEnabled
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (!alarm.isEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'OFF',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alarm.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: alarm.isEnabled
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAlarmDetails(),
                  ],
                ),
              ),

              // Controls
              Column(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: alarm.isEnabled,
                      onChanged: (_) => onToggle?.call(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmDetails() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        // Repeat days
        _buildDetailChip(icon: Icons.repeat, text: alarm.weekDaysString),

        // Sound
        if (alarm.soundPath.isNotEmpty)
          _buildDetailChip(
            icon: Icons.music_note,
            text: _getSoundDisplayName(alarm.soundPath),
          ),

        // Vibration
        if (alarm.vibrate)
          _buildDetailChip(icon: Icons.vibration, text: 'Vibrate'),
      ],
    );
  }

  Widget _buildDetailChip({required IconData icon, required String text}) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
