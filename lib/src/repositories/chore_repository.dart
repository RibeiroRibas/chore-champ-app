import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/chore.dart';

class ChoreRepository {
  ChoreRepository(this._client);

  final ApiClient _client;

  static const String _basePath = '/family/chores';

  Future<List<Chore>> fetchChores() async {
    try {
      final data = await _client.get<List<dynamic>>(_basePath);
      return (data)
          .map((e) => Chore.fromApiJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Chore> addChore(Chore chore) async {
    try {
      final body = <String, dynamic>{
        'title': chore.title,
        'emoji': chore.emoji,
        'points': chore.points,
        'completed': chore.completed,
      };
      if (chore.assignedTo != null && chore.assignedTo!.isNotEmpty) {
        body['assigned_to_user_id'] = int.tryParse(chore.assignedTo!);
      }
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        _basePath,
        body: body,
      );
      return Chore.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Chore> updateChore(Chore chore) async {
    try {
      final body = <String, dynamic>{
        'title': chore.title,
        'emoji': chore.emoji,
        'points': chore.points,
        'completed': chore.completed,
      };
      if (chore.assignedTo != null && chore.assignedTo!.isNotEmpty) {
        body['assigned_to_user_id'] = int.tryParse(chore.assignedTo!);
      } else {
        body['assigned_to_user_id'] = null;
      }
      final data = await _client.put<Map<String, dynamic>>(
        '$_basePath/${chore.id}',
        body: body,
      );
      return Chore.fromApiJson(data);
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

  Future<Chore> assignChoreToMe(String choreId) async {
    try {
      final data = await _client.patchWithResponse<Map<String, dynamic>>(
        '$_basePath/$choreId/assign-to-me',
      );
      return Chore.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Chore> removeAssignChoreToMe(String choreId) async {
    try {
      final data = await _client.patchWithResponse<Map<String, dynamic>>(
        '$_basePath/$choreId/remove-assign-to-me',
      );
      return Chore.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<Chore> completeChore(String choreId) async {
    try {
      final data = await _client.patchWithResponse<Map<String, dynamic>>(
        '$_basePath/$choreId/complete',
      );
      return Chore.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
