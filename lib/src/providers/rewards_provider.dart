import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chore_champ_app/src/models/reward.dart';
import 'repositories_provider.dart';

class RewardsNotifier extends AsyncNotifier<List<Reward>> {
  @override
  Future<List<Reward>> build() =>
      ref.read(rewardRepositoryProvider).fetchRewards();

  Future<void> addReward(Reward reward) async {
    final repo = ref.read(rewardRepositoryProvider);
    final created = await repo.addReward(reward);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateReward(String rewardId, Reward reward) async {
    final repo = ref.read(rewardRepositoryProvider);
    await repo.updateReward(reward);
    state = AsyncData(List.from(repo.rewards));
  }

  Future<void> deleteReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    await repo.deleteReward(rewardId);
    state = AsyncData(List.from(repo.rewards));
  }

  Future<void> claimReward(String rewardId, String memberId) async {
    final repo = ref.read(rewardRepositoryProvider);
    await repo.claimReward(rewardId, memberId);
    state = AsyncData(List.from(repo.rewards));
  }
}

final rewardsProvider = AsyncNotifierProvider<RewardsNotifier, List<Reward>>(RewardsNotifier.new);
