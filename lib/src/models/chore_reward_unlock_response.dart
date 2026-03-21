class ChoreRewardUnlockResponse {
  const ChoreRewardUnlockResponse({required this.newRewardUnlocked});

  final bool newRewardUnlocked;

  factory ChoreRewardUnlockResponse.fromJson(Map<String, dynamic> json) {
    return ChoreRewardUnlockResponse(
      newRewardUnlocked: json['new_reward_unlocked'] == true,
    );
  }
}
