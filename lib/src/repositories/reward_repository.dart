import 'package:chore_champ_app/src/models/reward.dart';

/// Repositório de recompensas (mock). Substituir por chamadas HTTP quando a API existir.
class RewardRepository {
  RewardRepository() : _rewards = List.from(_initialRewards);

  static final List<Reward> _initialRewards = [
    const Reward(
      id: 'r1',
      title: 'Tempo extra de tela',
      description: '30 min de tela bônus',
      emoji: '📱',
      achievementId: 'a2',
      claimedBy: ['3'],
    ),
    const Reward(
      id: 'r2',
      title: 'Escolher o filme da noite',
      description: 'Escolher o próximo filme em família',
      emoji: '🎬',
      achievementId: 'a3',
      claimedBy: [],
    ),
    const Reward(
      id: 'r3',
      title: 'Passeio do sorvete',
      description: 'Passeio em família para tomar sorvete!',
      emoji: '🍦',
      achievementId: 'a4',
      claimedBy: [],
    ),
    const Reward(
      id: 'r4',
      title: 'Pular uma tarefa',
      description: 'Passe livre para pular uma tarefa',
      emoji: '🎟️',
      achievementId: 'a2',
      claimedBy: ['4'],
    ),
  ];

  final List<Reward> _rewards;

  Future<List<Reward>> fetchRewards() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_rewards);
  }

  Future<Reward> addReward(Reward reward) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final id = 'r${DateTime.now().millisecondsSinceEpoch}';
    final created = reward.copyWith(id: id);
    _rewards.add(created);
    return created;
  }

  Future<void> updateReward(Reward reward) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final i = _rewards.indexWhere((r) => r.id == reward.id);
    if (i >= 0) _rewards[i] = reward;
  }

  Future<void> deleteReward(String rewardId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _rewards.removeWhere((r) => r.id == rewardId);
  }

  Future<void> claimReward(String rewardId, String memberId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final i = _rewards.indexWhere((r) => r.id == rewardId);
    if (i >= 0 && !_rewards[i].claimedBy.contains(memberId)) {
      _rewards[i] = _rewards[i].copyWith(
        claimedBy: [..._rewards[i].claimedBy, memberId],
      );
    }
  }

  List<Reward> get rewards => _rewards;
}
