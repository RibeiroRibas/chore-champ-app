import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/family_member.dart';

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

  Future<FamilyMember> fetchMember(int memberId) async {
    try {
      final data = await _client.get<dynamic>('$_basePath/$memberId');
      return FamilyMember.fromApiJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<FamilyMember> addMember({required FamilyMember member}) async {
    try {
      final body = <String, dynamic>{
        'name': member.name,
        'email': member.email,
        'phone': member.phoneNumber,
        'role_id': member.getRoleId(),
        'avatar': member.avatar,
      };
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

  Future<FamilyMember> updateMember(FamilyMember member) async {
    try {
      final body = <String, dynamic>{
        'name': member.name,
        'email': member.email,
        'phone': member.phoneNumber,
        'role_id': member.getRoleId(),
        'avatar': member.avatar,
      };
      final data = await _client.put<Map<String, dynamic>>(
        '$_basePath/${member.id}',
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
