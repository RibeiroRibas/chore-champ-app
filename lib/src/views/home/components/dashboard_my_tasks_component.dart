import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/views/home/components/chore_preview_card_component.dart';
import 'package:chore_champ_app/src/views/components/empty_chores_card_component.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardMyTasksComponent extends StatelessWidget {
  const DashboardMyTasksComponent({
    super.key,
    required this.myChores,
    this.onSeeAll,
  });

  final List<Chore> myChores;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.myTasks,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton(
              onPressed: onSeeAll ?? () => context.go('/chores'),
              child: const Text(AppStrings.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (myChores.isEmpty)
          const EmptyChoresCardComponent()
        else
          ...myChores
              .take(3)
              .map(
                (chore) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChorePreviewCardComponent(chore: chore),
                ),
              ),
      ],
    );
  }
}
