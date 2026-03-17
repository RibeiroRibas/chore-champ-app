import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/api_current_user.dart';

class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  Future<ApiCurrentUser> getCurrentUser() async {
    try {
      final data = await _client.get<Map<String, dynamic>>('/users/current');
      return ApiCurrentUser.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> createCurrentUser({
    required String name,
    required String phone,
    required String familyName,
  }) async {
    try {
      await _client.post(
        '/users/current-and-family',
        body: {'name': name, 'phone': phone, 'family_name': familyName},
      );
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
