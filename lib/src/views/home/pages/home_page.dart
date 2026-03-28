import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/infra/success_snackbar.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/family_ranking_provider.dart';
import 'package:chore_champ_app/src/providers/home_today_chores_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/infra/page_pull_refresh.dart';
import 'package:chore_champ_app/src/views/chores/components/chore_form_dialog_component.dart';
import 'package:chore_champ_app/src/views/chores/components/new_reward_unlocked_celebration_component.dart';
import 'package:chore_champ_app/src/views/home/components/dashboard_greeting_component.dart';
import 'package:chore_champ_app/src/views/home/components/dashboard_my_tasks_component.dart';
import 'package:chore_champ_app/src/views/home/components/leaderboard_row_component.dart';
import 'package:chore_champ_app/src/views/home/components/next_achievement_card_component.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _choreFormKey = GlobalKey<FormState>();
  bool _showChoreForm = false;

  void _showNewRewardUnlockedCelebration() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => NewRewardUnlockedCelebrationComponent(
        onClose: () => Navigator.of(ctx).pop(),
        onViewRewards: () {
          Navigator.of(ctx).pop();
          if (mounted) context.go('/rewards');
        },
      ),
    );
  }

  Future<void> _handleSaveChore(Chore chore) async {
    try {
      final unlocked = chore.id.isNotEmpty
          ? await ref.read(choresProvider.notifier).updateChore(chore)
          : await ref.read(choresProvider.notifier).addChore(chore);
      if (!mounted) return;
      final String successMessage;
      if (chore.id.isNotEmpty) {
        successMessage = AppStrings.choreUpdated;
      } else {
        final ids = chore.assignedToUserIds;
        final n = (ids == null || ids.isEmpty) ? 1 : ids.length;
        successMessage = n > 1
            ? AppStrings.choresCreatedMultiple
            : AppStrings.choreCreated;
      }
      showSuccessSnackBar(
        context,
        message: successMessage,
      );
      setState(() => _showChoreForm = false);
      if (unlocked) _showNewRewardUnlockedCelebration();
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = ref.watch(currentMemberProvider);
    final homeTodayAsync = ref.watch(homeTodayChoresProvider);
    final membersAsync = ref.watch(membersProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return currentMember.when(
      data: (member) => homeTodayAsync.when(
        data: (myTodayChores) {
          final myChores =
              myTodayChores.where((c) => !c.completed).toList();
          final completedToday =
              myTodayChores.where((c) => c.completed).length;
          final totalChores = myTodayChores.length;

          return membersAsync.when(
            data: (_) {
              return achievementsAsync.when(
                data: (achievements) {
                  Achievement? nextAchievement;
                  try {
                    nextAchievement = achievements.firstWhere(
                      (a) =>
                          a.acquiredTimes == 0 &&
                          a.requiredPoints > member.points,
                    );
                  } catch (_) {}
                  final progress = nextAchievement != null
                      ? (member.points /
                                nextAchievement.requiredPoints *
                                100)
                            .clamp(0.0, 100.0)
                      : 100.0;

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () => pullRefreshHome(ref),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardGreetingComponent(
                                currentUser: member,
                                completedToday: completedToday,
                                totalChores: totalChores,
                              ),
                              const SizedBox(height: 20),
                              DashboardMyTasksComponent(
                                myChores: myChores,
                                onAddChore: member.isAdmin()
                                    ? () => setState(() => _showChoreForm = true)
                                    : null,
                              ),
                              if (nextAchievement != null) ...[
                                const SizedBox(height: 20),
                                NextAchievementCardComponent(
                                  currentUser: member,
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
                        ),
                      ),
                      if (_showChoreForm)
                        ChoreFormDialogComponent(
                          formKey: _choreFormKey,
                          chore: null,
                          currentMember: member,
                          onCancel: () =>
                              setState(() => _showChoreForm = false),
                          onSave: _handleSaveChore,
                        ),
                    ],
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
