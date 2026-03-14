import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<void> sendEmailCreateAuthCode(String email) async {
    try {
      await _client.post('/auth/send-email-create-auth-code/${Uri.encodeComponent(email)}');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> createAuth({
    required String email,
    required String password,
    required int emailConfirmationCode,
  }) async {
    try {
      await _client.post('/auth', body: {
        'email': email,
        'password': password,
        'email_confirmation_code': emailConfirmationCode,
      });
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String? ?? '';
      return LoginResult(accessToken: accessToken, refreshToken: refreshToken);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<LoginResult> refreshToken({
    required String refreshToken,
    required int currentUserId,
  }) async {
    try {
      final data = await _client.postWithResponse<Map<String, dynamic>>(
        '/auth/refresh',
        body: {
          'refresh_token': refreshToken,
          'current_user_id': currentUserId,
        },
      );
      final accessToken = data['access_token'] as String? ?? '';
      final newRefreshToken = data['refresh_token'] as String? ?? '';
      return LoginResult(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> sendEmailForgetPasswordCode(String email) async {
    try {
      await _client.post('/auth/send-email-forget-password-code/${Uri.encodeComponent(email)}');
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required int confirmationCode,
    required String password,
  }) async {
    try {
      await _client.patch('/auth/reset-password', body: {
        'email': email,
        'confirmation_code': confirmationCode,
        'password': password,
      });
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
