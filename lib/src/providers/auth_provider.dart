import 'package:chore_champ_app/src/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories_provider.dart';

class AuthNotifier extends Notifier<void> {
  @override
  void build() {}

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Future<void> sendEmailCreateAuthCode(String email) async {
    await _auth.sendEmailCreateAuthCode(email);
  }

  Future<void> sendEmailForgetPasswordCode(String email) async {
    await _auth.sendEmailForgetPasswordCode(email);
  }

  Future<void> resetPassword({
    required String email,
    required int confirmationCode,
    required String password,
  }) async {
    await _auth.resetPassword(
      email: email,
      confirmationCode: confirmationCode,
      password: password,
    );
  }

  Future<void> createAuth({
    required String email,
    required String password,
    required int emailConfirmationCode,
  }) async {
    await _auth.createAuth(
      email: email,
      password: password,
      emailConfirmationCode: emailConfirmationCode,
    );
  }

  Future<LoginResult> login(String email, String password) async {
    return _auth.login(email, password);
  }
}

final authProvider = NotifierProvider<AuthNotifier, void>(AuthNotifier.new);
