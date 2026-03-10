import 'package:dio/dio.dart';

import '../infra/api_client.dart';
import '../models/family_member.dart';

class FamilyRepository {
  FamilyRepository(this._client);

  final ApiClient _client;

  static const String _basePath = '/family/users';

  Future<List<FamilyMember>> fetchMembers() async {
    try {
      final data = await _client.get<List<dynamic>>(_basePath);
      return data
          .map((e) => FamilyMember.fromApiJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<FamilyMember> addMember({
    required String name,
    required String email,
    required String phone,
    required int roleId,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'role_id': roleId,
      };
      if (avatar != null && avatar.isNotEmpty) body['avatar'] = avatar;
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        _basePath,
        body: body,
      );
      return FamilyMember.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<FamilyMember> updateMember(
    String memberId, {
    required String name,
    required String email,
    required String phone,
    required int roleId,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'role_id': roleId,
      };
      if (avatar != null && avatar.isNotEmpty) body['avatar'] = avatar;
      final data = await _client.put<Map<String, dynamic>>(
        '$_basePath/$memberId',
        body: body,
      );
      return FamilyMember.fromApiJson(data);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await _client.delete('$_basePath/$memberId');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> resendPassword(String memberId) async {
    try {
      await _client.post('$_basePath/$memberId/resend-password');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

}
