import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/achievement.dart';

class AchievementRepository {
  AchievementRepository(this._client);

  final ApiClient _client;

  Future<List<Achievement>> fetchAchievements() async {
    try {
      final data =
          await _client.get<List<dynamic>>('/family/users/achievements');
      return data
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
