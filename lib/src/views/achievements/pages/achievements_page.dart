import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:chore_champ_app/src/views/achievements/components/achievement_card_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMember = ref.watch(currentMemberProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return currentMember.when(
      data: (currentMember) => achievementsAsync.when(
        data: (achievements) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.achievements,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, i) {
                    final a = achievements[i];
                    final unlocked = currentMember.points >= a.requiredPoints;
                    final progress =
                        (currentMember.points / a.requiredPoints * 100).clamp(
                          0.0,
                          100.0,
                        );
                    return AchievementCardComponent(
                      achievement: a,
                      unlocked: unlocked,
                      progress: progress,
                      currentUserPoints: currentMember.points,
                      acquiredTimes: a.acquiredTimes,
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
    );
  }
}
