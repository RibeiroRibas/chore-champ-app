import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/family_ranking_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/views/home/components/dashboard_greeting_component.dart';
import 'package:chore_champ_app/src/views/home/components/dashboard_my_tasks_component.dart';
import 'package:chore_champ_app/src/views/home/components/leaderboard_row_component.dart';
import 'package:chore_champ_app/src/views/home/components/next_achievement_card_component.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMember = ref.watch(currentMemberProvider);
    final choresAsync = ref.watch(choresProvider);
    final membersAsync = ref.watch(membersProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return currentMember.when(
      data: (currentMember) => choresAsync.when(
        data: (choresState) => choresState.today.when(
          data: (chores) {
            final myChores = chores
                .where((c) => c.assignedTo == currentMember.id && !c.completed)
                .toList();
            final completedToday = chores.where((c) => c.completed && c.assignedTo == currentMember.id).length;
            final totalChores = chores.where((c) => c.assignedTo == currentMember.id).length;

            return membersAsync.when(
              data: (_) {
                return achievementsAsync.when(
                  data: (achievements) {
                    Achievement? nextAchievement;
                    try {
                      nextAchievement = achievements.firstWhere(
                        (a) =>
                            a.acquiredTimes == 0 &&
                            a.requiredPoints > currentMember.points,
                      );
                    } catch (_) {}
                    final progress = nextAchievement != null
                        ? (currentMember.points /
                                  nextAchievement.requiredPoints *
                                  100)
                              .clamp(0.0, 100.0)
                        : 100.0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardGreetingComponent(
                            currentUser: currentMember,
                            completedToday: completedToday,
                            totalChores: totalChores,
                          ),
                          const SizedBox(height: 20),
                          DashboardMyTasksComponent(myChores: myChores),
                          if (nextAchievement != null) ...[
                            const SizedBox(height: 20),
                            NextAchievementCardComponent(
                              currentUser: currentMember,
                              nextAchievement: nextAchievement,
                              progress: progress,
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.leaderboard,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          _RankingSection(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
    );
  }
}

class _RankingSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const medals = ['🥇', '🥈', '🥉'];
    final rankingAsync = ref.watch(familyRankingProvider);

    return rankingAsync.when(
      data: (ranking) {
        return Column(
          children: ranking.asMap().entries.map((entry) {
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
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(AppStrings.errorGeneric),
    );
  }
}
