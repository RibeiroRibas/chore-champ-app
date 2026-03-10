import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/family_member.dart';
import '../../widgets/card_playful.dart';

class MemberCardComponent extends StatelessWidget {
  const MemberCardComponent({
    super.key,
    required this.member,
    required this.tasksCount,
    required this.completedCount,
    required this.achievementsCount,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  final FamilyMember member;
  final int tasksCount;
  final int completedCount;
  final int achievementsCount;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
                            member.role == Role.admin ? Icons.shield : Icons.person,
                            size: 14,
                            color: member.role == Role.admin ? AppColors.primary : AppColors.mutedForeground,
                          ),
                        ],
                      ),
                      Text(
                        member.role == Role.admin
                            ? AppStrings.roleAdmin
                            : AppStrings.roleCollaborator,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
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
