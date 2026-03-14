import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/achievement.dart';
import 'package:chore_champ_app/src/models/reward.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/rewards_provider.dart';
import 'package:chore_champ_app/src/views/rewards/components/delete_reward_dialog_component.dart';
import 'package:chore_champ_app/src/views/rewards/components/reward_card_component.dart';
import 'package:chore_champ_app/src/views/rewards/components/reward_form_dialog_component.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  bool _dialogOpen = false;
  Reward? _editingReward;
  String? _deleteId;
  String _title = '';
  String _description = '';
  String _emoji = '🎁';
  String _achievementId = '';

  void _openCreate(List<Achievement> achievements) {
    setState(() {
      _editingReward = null;
      _title = '';
      _description = '';
      _emoji = '🎁';
      _achievementId = achievements.isNotEmpty ? achievements.first.id : '';
      _dialogOpen = true;
    });
  }

  void _openEdit(Reward reward) {
    setState(() {
      _editingReward = reward;
      _title = reward.title;
      _description = reward.description;
      _emoji = reward.emoji;
      _achievementId = reward.achievementId;
      _dialogOpen = true;
    });
  }

  void _handleSave() {
    if (_title.trim().isEmpty || _achievementId.isEmpty) return;
    if (_editingReward != null) {
      ref
          .read(rewardsProvider.notifier)
          .updateReward(
            _editingReward!.id,
            _editingReward!.copyWith(
              title: _title.trim(),
              description: _description.trim(),
              emoji: _emoji,
              achievementId: _achievementId,
            ),
          );
    } else {
      ref
          .read(rewardsProvider.notifier)
          .addReward(
            Reward(
              id: '',
              title: _title.trim(),
              description: _description.trim(),
              emoji: _emoji,
              achievementId: _achievementId,
              claimedBy: [],
            ),
          );
    }
    setState(() => _dialogOpen = false);
  }

  void _handleDelete() {
    if (_deleteId != null) {
      ref.read(rewardsProvider.notifier).deleteReward(_deleteId!);
      setState(() => _deleteId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = ref.watch(currentMemberProvider);
    final rewardsAsync = ref.watch(rewardsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return currentMember.when(
      data: (currentMember) {
        return rewardsAsync.when(
          data: (rewards) {
            return achievementsAsync.when(
              data: (achievements) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.rewards,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (currentMember.isAdmin())
                                TextButton.icon(
                                  onPressed: () => _openCreate(achievements),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text(AppStrings.add),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (rewards.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Text(
                                  '${AppStrings.noRewardsYet} ${currentMember.isAdmin() ? AppStrings.createFirstReward : AppStrings.askAdminToAddRewards}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ...rewards.map((reward) {
                              Achievement? achievement;
                              try {
                                achievement = achievements.firstWhere(
                                  (a) => a.id == reward.achievementId,
                                );
                              } catch (_) {}
                              final achievementUnlocked =
                                  achievement?.unlockedBy.contains(
                                    currentMember.id,
                                  ) ??
                                  false;
                              final claimed = reward.claimedBy.contains(
                                currentMember.id,
                              );
                              final canClaim = achievementUnlocked && !claimed;

                              return RewardCardComponent(
                                reward: reward,
                                achievement: achievement,
                                claimed: claimed,
                                canClaim: canClaim,
                                isAdmin: currentMember.isAdmin(),
                                onEdit: () => _openEdit(reward),
                                onDelete: () =>
                                    setState(() => _deleteId = reward.id),
                                onClaim: () => ref
                                    .read(rewardsProvider.notifier)
                                    .claimReward(reward.id, currentMember.id),
                              );
                            }),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    if (_dialogOpen)
                      RewardFormDialogComponent(
                        isEditing: _editingReward != null,
                        title: _title,
                        description: _description,
                        emoji: _emoji,
                        achievementId: _achievementId,
                        achievements: achievements,
                        onTitleChanged: (v) => setState(() => _title = v),
                        onDescriptionChanged: (v) =>
                            setState(() => _description = v),
                        onEmojiChanged: (v) => setState(() => _emoji = v),
                        onAchievementIdChanged: (v) =>
                            setState(() => _achievementId = v ?? ''),
                        onCancel: () => setState(() => _dialogOpen = false),
                        onSave: _handleSave,
                        canSave:
                            _title.trim().isNotEmpty &&
                            _achievementId.isNotEmpty,
                      ),
                    if (_deleteId != null)
                      DeleteRewardDialogComponent(
                        onCancel: () => setState(() => _deleteId = null),
                        onConfirm: _handleDelete,
                      ),
                  ],
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
