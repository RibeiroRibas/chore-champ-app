import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../infra/api_exception.dart';
import '../models/api_current_user.dart';
import 'auth_provider.dart';
import 'current_user_provider.dart';
import 'repositories_provider.dart';
import 'user_provider.dart';

class SessionState {
  const SessionState({
    this.accessToken,
    this.apiCurrentUser,
    this.needFirstAccess = false,
  });

  final String? accessToken;
  final ApiCurrentUser? apiCurrentUser;
  final bool needFirstAccess;

  bool get isLoggedIn => accessToken != null && apiCurrentUser != null && !needFirstAccess;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  void _setToken(String token) {
    ref.read(apiClientProvider).setAccessToken(token);
    state = SessionState(accessToken: token, needFirstAccess: state.needFirstAccess);
  }

  Future<void> login(String email, String password) async {
    final loginResult = await ref.read(authProvider.notifier).login(email, password);
    _setToken(loginResult.accessToken);
    try {
      final user = await ref.read(userProvider.notifier).getCurrentUser();
      state = SessionState(
        accessToken: state.accessToken,
        apiCurrentUser: user,
        needFirstAccess: false,
      );
      ref.read(currentUserIdProvider.notifier).setCurrentUserId(user.id.toString());
    } on ApiException catch (e) {
      if (e.code == ApiConstants.codeUserNotFound) {
        state = SessionState(
          accessToken: state.accessToken,
          needFirstAccess: true,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> completeFirstAccess({
    required String name,
    required String phone,
    required String familyName,
  }) async {
    final userNotifier = ref.read(userProvider.notifier);
    await userNotifier.createCurrentUser(name: name, phone: phone, familyName: familyName);
    final user = await userNotifier.getCurrentUser();
    state = SessionState(
      accessToken: state.accessToken,
      apiCurrentUser: user,
      needFirstAccess: false,
    );
    ref.read(currentUserIdProvider.notifier).setCurrentUserId(user.id.toString());
  }

  void logout() {
    ref.read(apiClientProvider).setAccessToken(null);
    ref.read(currentUserIdProvider.notifier).setCurrentUserId('');
    state = const SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
