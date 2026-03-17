import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:flutter/material.dart';

const _emojiOptions = [
  '📱',
  '🎬',
  '🍦',
  '🎟️',
  '🎮',
  '🛍️',
  '🍕',
  '⭐',
  '🎁',
  '🏖️',
  '🎵',
  '📚',
];

class RewardFormDialogComponent extends StatelessWidget {
  const RewardFormDialogComponent({
    super.key,
    required this.isEditing,
    required this.title,
    required this.description,
    required this.emoji,
    required this.achievementId,
    required this.achievements,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onEmojiChanged,
    required this.onAchievementIdChanged,
    required this.onCancel,
    required this.onSave,
    required this.canSave,
  });

  final bool isEditing;
  final String title;
  final String description;
  final String emoji;
  final String achievementId;
  final List<Achievement> achievements;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onEmojiChanged;
  final ValueChanged<String?> onAchievementIdChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool canSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? AppStrings.editReward : AppStrings.newReward,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.emoji,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojiOptions.map((e) {
                    final selected = emoji == e;
                    return GestureDetector(
                      onTap: () => onEmojiChanged(e),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: title,
                  onChanged: onTitleChanged,
                  decoration: const InputDecoration(
                    labelText: AppStrings.rewardTitle,
                    hintText: AppStrings.rewardTitleHint,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: description,
                  onChanged: onDescriptionChanged,
                  decoration: const InputDecoration(
                    labelText: AppStrings.rewardDescription,
                    hintText: AppStrings.rewardDescriptionHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.requiredAchievement,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                if (achievements.isEmpty)
                  const Text(
                    AppStrings.noAchievementsAvailable,
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 14,
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: achievementId.isEmpty
                        ? achievements.first.id
                        : achievementId,
                    decoration: const InputDecoration(),
                    items: achievements
                        .map(
                          (a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(
                              '${a.emoji} ${a.title} (${a.requiredPoints} pts)',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onAchievementIdChanged,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text(AppStrings.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: canSave ? onSave : null,
                      child: Text(
                        isEditing
                            ? AppStrings.saveChanges
                            : AppStrings.createReward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
