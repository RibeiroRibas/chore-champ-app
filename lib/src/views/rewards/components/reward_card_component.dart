import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:chore_champ_app/src/models/reward.dart';
import 'package:chore_champ_app/src/views/widgets/card_playful.dart';
import 'package:chore_champ_app/src/views/widgets/gradient_warm.dart';
import 'package:flutter/material.dart';

class RewardCardComponent extends StatelessWidget {
  const RewardCardComponent({
    super.key,
    required this.reward,
    this.achievement,
    required this.claimed,
    required this.canClaim,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
    this.onClaim,
  });

  final Reward reward;
  final Achievement? achievement;
  final bool claimed;
  final bool canClaim;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardPlayful(
        child: Row(
          children: [
            Text(reward.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.title, style: Theme.of(context).textTheme.titleSmall),
                  Text(reward.description, style: Theme.of(context).textTheme.bodySmall),
                  if (achievement != null)
                    Text(
                      '${AppStrings.requiresAchievement}${achievement!.emoji} ${achievement!.title}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedForeground),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.destructive),
                  ),
                ],
                if (claimed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      AppStrings.claimed,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.success),
                    ),
                  )
                else if (canClaim)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onClaim,
                      borderRadius: BorderRadius.circular(20),
                      child: GradientWarm(
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            AppStrings.claimReward,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.locked,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
