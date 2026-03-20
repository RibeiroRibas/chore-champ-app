import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chore_champ_app/src/models/reward.dart';
import 'achievements_provider.dart';
import 'repositories_provider.dart';

class RewardsNotifier extends AsyncNotifier<List<Reward>> {
  @override
  Future<List<Reward>> build() =>
      ref.read(rewardRepositoryProvider).fetchRewards();

  Future<void> addReward(Reward reward) async {
    final repo = ref.read(rewardRepositoryProvider);
    final created = await repo.addReward(reward);
    state = AsyncData([...?state.valueOrNull, created]);
  }

  Future<void> updateReward(String rewardId, Reward reward) async {
    final repo = ref.read(rewardRepositoryProvider);
    final updated = await repo.updateReward(reward.copyWith(id: rewardId));
    final current = state.valueOrNull ?? const <Reward>[];
    state = AsyncData(
      current.map((item) => item.id == rewardId ? updated : item).toList(),
    );
  }

  Future<void> deleteReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    await repo.deleteReward(rewardId);
    final current = state.valueOrNull ?? const <Reward>[];
    state = AsyncData(current.where((item) => item.id != rewardId).toList());
  }

  Future<void> claimReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    await repo.claimReward(rewardId);
    final refreshed = await repo.fetchRewards();
    state = AsyncData(refreshed);
    ref.invalidate(achievementsProvider);
  }
}

final rewardsProvider = AsyncNotifierProvider<RewardsNotifier, List<Reward>>(
  RewardsNotifier.new,
);
