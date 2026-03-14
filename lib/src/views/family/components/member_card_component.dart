import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/views/widgets/card_playful.dart';
import 'package:flutter/material.dart';

class MemberCardComponent extends StatelessWidget {
  const MemberCardComponent({
    super.key,
    required this.member,
    required this.tasksCount,
    required this.completedCount,
    required this.achievementsCount,
    required this.hasAdminPermission,
    this.onEdit,
    this.onDelete,
  });

  final FamilyMember member;
  final int tasksCount;
  final int completedCount;
  final int achievementsCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool hasAdminPermission;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardPlayful(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(member.avatar, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(member.name, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(width: 6),
                          Icon(
                            member.isAdmin() ? Icons.shield : Icons.person,
                            size: 14,
                            color: member.isAdmin() ? AppColors.primary : AppColors.mutedForeground,
                          ),
                        ],
                      ),
                      Text(
                        member.isAdmin()
                            ? AppStrings.roleAdmin
                            : AppStrings.roleCollaborator,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasAdminPermission) ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedForeground),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.destructive),
                  ),
                ],
                Text(
                  '${member.points} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '📋 $tasksCount ${AppStrings.tasksCountLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  '✅ $completedCount ${AppStrings.doneLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  '🏆 $achievementsCount ${AppStrings.achievementsCountLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
