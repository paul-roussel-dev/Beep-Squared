import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/ringtone_service.dart';
import '../constants/constants.dart';

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

  /// Get icon for unlock method
  IconData _getUnlockMethodIcon(AlarmUnlockMethod method) {
    switch (method) {
      case AlarmUnlockMethod.simple:
        return Icons.touch_app;
      case AlarmUnlockMethod.math:
        return Icons.calculate;
    }
  }

  /// Get text for unlock method
  String _getUnlockMethodText(AlarmUnlockMethod method) {
    switch (method) {
      case AlarmUnlockMethod.simple:
        return AppStrings.alarmTypeClassic;
      case AlarmUnlockMethod.math:
        final difficultyText = _getMathDifficultyText(alarm.mathDifficulty);
        return AppStrings.mathDifficultyDisplay(difficultyText);
    }
  }

  /// Get text for math difficulty
  String _getMathDifficultyText(MathDifficulty difficulty) {
    switch (difficulty) {
      case MathDifficulty.easy:
        return AppStrings.mathEasy;
      case MathDifficulty.medium:
        return AppStrings.mathMedium;
      case MathDifficulty.hard:
        return AppStrings.mathHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSizes.marginCard,
      elevation: alarm.isEnabled ? 2 : 1,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Padding(
          padding: AppSizes.paddingCard,
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
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                        ),
                        const SizedBox(width: AppSizes.spacingSmall),
                        if (!alarm.isEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spacingSmall,
                              vertical: AppSizes.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                            child: const Text(
                              AppStrings.alarmOff,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      alarm.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
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
                      padding: AppSizes.paddingAll,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        size: AppSizes.iconMedium,
                        color: AppColors.white,
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case AppStrings.edit:
                          onEdit?.call();
                          break;
                        case AppStrings.delete:
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: AppStrings.edit,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: AppSizes.iconSmall,
                              color: AppColors.white,
                            ),
                            SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              AppStrings.editAlarm,
                              style: TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: AppStrings.delete,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: AppSizes.iconSmall,
                              color: AppColors.white,
                            ),
                            SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              AppStrings.delete,
                              style: TextStyle(color: AppColors.white),
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
        // Unlock method (type d'alarme) - First to highlight the alarm type
        _buildDetailChip(
          icon: _getUnlockMethodIcon(alarm.unlockMethod),
          text: _getUnlockMethodText(alarm.unlockMethod),
          isPrimary: true, // Highlight the alarm type
        ),

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
          _buildDetailChip(icon: Icons.vibration, text: AppStrings.vibrate),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    bool isPrimary = false,
  }) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: AppSizes.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconSmall - 2, // 14
              color: AppColors.white,
            ),
            const SizedBox(width: AppSizes.spacingXs),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
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
