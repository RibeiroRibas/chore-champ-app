import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_strings.dart';
import '../../../models/achievement.dart';
import '../../../models/chore.dart';
import '../../../models/family_member.dart';
import '../../../providers/achievements_provider.dart';
import '../../../providers/chores_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/members_provider.dart';
import '../components/dashboard_greeting_component.dart';
import '../components/dashboard_my_tasks_component.dart';
import '../components/leaderboard_row_component.dart';
import '../components/next_achievement_card_component.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final choresAsync = ref.watch(choresProvider);
    final membersAsync = ref.watch(membersProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return choresAsync.when(
      data: (chores) {
        final myChores = chores.where((c) => c.assignedTo == currentUser.id && !c.completed).toList();
        final completedToday = chores.where((c) => c.completed).length;
        final totalChores = chores.length;

        return membersAsync.when(
          data: (members) {
            final sortedMembers = List<FamilyMember>.from(members)..sort((a, b) => b.points.compareTo(a.points));
            return achievementsAsync.when(
              data: (achievements) {
                Achievement? nextAchievement;
                try {
                  nextAchievement = achievements.firstWhere(
                    (a) => !a.unlockedBy.contains(currentUser.id) && a.requiredPoints > currentUser.points,
                  );
                } catch (_) {}
                final progress = nextAchievement != null
                    ? (currentUser.points / nextAchievement.requiredPoints * 100).clamp(0.0, 100.0)
                    : 100.0;

                const medals = ['🥇', '🥈', '🥉'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardGreetingComponent(
                        currentUser: currentUser,
                        completedToday: completedToday,
                        totalChores: totalChores,
                      ),
                      const SizedBox(height: 20),
                      DashboardMyTasksComponent(myChores: myChores),
                      if (nextAchievement != null) ...[
                        const SizedBox(height: 20),
                        NextAchievementCardComponent(
                          currentUser: currentUser,
                          nextAchievement: nextAchievement,
                          progress: progress,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(AppStrings.leaderboard, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      ...sortedMembers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final member = entry.value;
                        final rankDisplay = i < 3 ? medals[i] : '${i + 1}';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeaderboardRowComponent(
                            member: member,
                            rankDisplay: rankDisplay,
                          ),
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
    );
  }
}
