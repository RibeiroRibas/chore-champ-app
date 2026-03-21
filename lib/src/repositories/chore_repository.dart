import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/filters/all_chores_filters.dart';
import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/chore_reward_unlock_response.dart';
import 'package:chore_champ_app/src/models/paginated_chores_response.dart';

class ChoreRepository {
  ChoreRepository(this._client);

  final ApiClient _client;

  static const String _basePath = '/family/chores';

  Future<List<Chore>> fetchTodayChores() async {
    try {
      final data = await _client.get<List<dynamic>>('$_basePath/today');
      return (data)
          .map((e) => Chore.fromApiJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<PaginatedChoresResponse> fetchAllChores(
    AllChoresFilters filters,
  ) async {
    try {
      final query = <String, dynamic>{
        'page': filters.page,
        'page_size': filters.pageSize,
      };

      if (filters.title.trim().isNotEmpty) {
        query['title'] = filters.title.trim();
      }
      if (filters.isRecurring) {
        query['is_recurring'] = true;
      }
      if (filters.completed) {
        query['completed'] = true;
      }
      if (filters.assignedToUserId != null &&
          filters.assignedToUserId!.isNotEmpty) {
        query['assigned_to_user_id'] = int.tryParse(filters.assignedToUserId!);
      }

      final data = await _client.get<Map<String, dynamic>>(
        '$_basePath/all',
        queryParameters: query,
      );
      return PaginatedChoresResponse.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<bool> addChore(Chore chore) async {
    try {
      final body = <String, dynamic>{
        'title': chore.title,
        'emoji': chore.emoji,
        'points': chore.points,
        'completed': chore.completed,
        'is_recurring': chore.isRecurring,
      };
      if (chore.assignedTo != null && chore.assignedTo!.isNotEmpty) {
        body['assigned_to_user_id'] = int.tryParse(chore.assignedTo!);
      }
      if (chore.isRecurring && chore.recurrenceDayIds.isNotEmpty) {
        body['recurrence_day_ids'] = chore.recurrenceDayIds;
      }
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        _basePath,
        body: body,
      );
      return ChoreRewardUnlockResponse.fromJson(data).newRewardUnlocked;
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<bool> updateChore(Chore chore) async {
    try {
      final body = <String, dynamic>{
        'title': chore.title,
        'emoji': chore.emoji,
        'points': chore.points,
        'completed': chore.completed,
        'is_recurring': chore.isRecurring,
      };
      if (chore.assignedTo != null && chore.assignedTo!.isNotEmpty) {
        body['assigned_to_user_id'] = int.tryParse(chore.assignedTo!);
      } else {
        body['assigned_to_user_id'] = null;
      }
      if (chore.isRecurring && chore.recurrenceDayIds.isNotEmpty) {
        body['recurrence_day_ids'] = chore.recurrenceDayIds;
      }
      final data = await _client.put<Map<String, dynamic>>(
        '$_basePath/${chore.id}',
        body: body,
      );
      return ChoreRewardUnlockResponse.fromJson(data).newRewardUnlocked;
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> deleteChore(String choreId) async {
    try {
      await _client.delete('$_basePath/$choreId');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> assignChoreToMe(String choreId) async {
    try {
      await _client.patch('$_basePath/$choreId/assign-to-me');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> removeAssignChoreToMe(String choreId) async {
    try {
      await _client.patch('$_basePath/$choreId/remove-assign-to-me');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<bool> completeChore(String choreId) async {
    try {
      final data = await _client.patchWithResponse<Map<String, dynamic>>(
        '$_basePath/$choreId/complete',
      );
      return ChoreRewardUnlockResponse.fromJson(data).newRewardUnlocked;
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
