import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:chore_champ_app/src/views/widgets/card_playful.dart';
import 'package:flutter/material.dart';

class AchievementCardComponent extends StatelessWidget {
  const AchievementCardComponent({
    super.key,
    required this.achievement,
    required this.unlocked,
    required this.progress,
    required this.currentUserPoints,
  });

  final Achievement achievement;
  final bool unlocked;
  final double progress;
  final int currentUserPoints;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Opacity(
        opacity: unlocked ? 1 : 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(achievement.emoji, style: const TextStyle(fontSize: 40)),
                if (!unlocked)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock, size: 12, color: AppColors.mutedForeground),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!unlocked) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.muted,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentUserPoints/${achievement.requiredPoints} pts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
            if (unlocked) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  AppStrings.unlocked,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.success),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
