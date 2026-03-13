import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/chore.dart';
import '../../widgets/card_playful.dart';

class ChoreRowComponent extends StatelessWidget {
  const ChoreRowComponent({
    super.key,
    required this.chore,
    required this.assignedToName,
    required this.completed,
    required this.onToggle,
    this.onClaim,
    this.onDelete,
    this.showClaim = false,
    this.showDelete = false,
  });

  final Chore chore;
  final String assignedToName;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback? onClaim;
  final VoidCallback? onDelete;
  final bool showClaim;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CardPlayful(
        child: Opacity(
          opacity: completed ? 0.6 : 1,
          child: Row(
            children: [
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  Icons.check_circle,
                  color: completed ? AppColors.success : AppColors.mutedForeground,
                  size: 22,
                ),
              ),
              Text(chore.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chore.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      assignedToName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${chore.points}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: completed ? AppColors.mutedForeground : AppColors.primary,
                    ),
                  ),
                  if (showClaim && !completed) ...[
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: onClaim,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(AppStrings.claim, style: TextStyle(fontSize: 10)),
                    ),
                  ],
                  if (showDelete) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.destructive),
                      style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
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
