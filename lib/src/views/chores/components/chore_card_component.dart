import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/views/widgets/card_playful.dart';
import 'package:flutter/material.dart';

class ChoreCardComponent extends StatelessWidget {
  const ChoreCardComponent({
    super.key,
    required this.chore,
    required this.assignedToName,
    required this.completed,
    required this.onToggle,
    this.onEdit,
    this.onAssignToMe,
    this.onRemoveAssignment,
    this.onComplete,
    this.onDelete,
    this.showEdit = false,
    this.showAssignToMe = false,
    this.showRemoveAssignment = false,
    this.showComplete = false,
    this.showDelete = false,
  });

  final Chore chore;
  final String assignedToName;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onAssignToMe;
  final VoidCallback? onRemoveAssignment;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final bool showEdit;
  final bool showAssignToMe;
  final bool showRemoveAssignment;
  final bool showComplete;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CardPlayful(
        padding: const EdgeInsets.all(12),
        child: Opacity(
          opacity: completed ? 0.6 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        Icons.check_circle,
                        color: completed
                            ? AppColors.success
                            : AppColors.mutedForeground,
                        size: 22,
                      ),
                    ),
                    Text(chore.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chore.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          assignedToName,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${chore.points}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? AppColors.mutedForeground
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showEdit && !completed) ...[
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.mutedForeground,
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                      if (showDelete) ...[
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.destructive,
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if ((showAssignToMe || showRemoveAssignment) && !completed)
                    if (showAssignToMe)
                      TextButton(
                        onPressed: onAssignToMe,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.assignToMe,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                  if (showRemoveAssignment)
                    TextButton(
                      onPressed: onRemoveAssignment,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.removeAssignment,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (showComplete) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onComplete,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.completeButton,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
