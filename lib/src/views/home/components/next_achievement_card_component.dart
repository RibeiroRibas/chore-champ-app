import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/achievement.dart';
import '../../../models/family_member.dart';
import '../../widgets/card_playful.dart';

class NextAchievementCardComponent extends StatelessWidget {
  const NextAchievementCardComponent({
    super.key,
    required this.currentUser,
    required this.nextAchievement,
    required this.progress,
  });

  final FamilyMember currentUser;
  final Achievement nextAchievement;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(nextAchievement.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nextAchievement.title, style: Theme.of(context).textTheme.titleSmall),
                    Text(nextAchievement.description, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: AppColors.muted,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${currentUser.points}/${nextAchievement.requiredPoints} pts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
