import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/reward.dart';

class RewardRepository {
  RewardRepository(this._client);

  final ApiClient _client;

  Future<List<Reward>> fetchRewards() async {
    try {
      final data = await _client.get<List<dynamic>>('/family/rewards');
      return data
          .map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Reward> addReward(Reward reward) async {
    try {
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        '/family/rewards',
        body: {
          'title': reward.title,
          'subtitle': reward.description.isEmpty ? null : reward.description,
          'emoji': reward.emoji,
          'achievement_id': int.parse(reward.achievementId),
        },
      );
      return Reward.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Reward> updateReward(Reward reward) async {
    try {
      final data = await _client.put<Map<String, dynamic>>(
        '/family/rewards/${int.parse(reward.id)}',
        body: {
          'title': reward.title,
          'subtitle': reward.description.isEmpty ? null : reward.description,
          'emoji': reward.emoji,
          'achievement_id': int.parse(reward.achievementId),
        },
      );
      return Reward.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> deleteReward(String rewardId) async {
    try {
      await _client.delete('/family/rewards/${int.parse(rewardId)}');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Reward> claimReward(String rewardId) async {
    try {
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        '/family/rewards/${int.parse(rewardId)}/claim',
      );
      return Reward.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
