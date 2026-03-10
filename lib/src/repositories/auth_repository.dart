import 'package:dio/dio.dart';

import '../infra/api_client.dart';

class LoginResult {
  const LoginResult({required this.accessToken});
  final String accessToken;
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
      final token = data['access_token'] ?? '';
      return LoginResult(accessToken: token);
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }

}
