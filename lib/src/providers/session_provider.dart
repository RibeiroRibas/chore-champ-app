import 'dart:convert';

import 'package:chore_champ_app/src/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../infra/api_exception.dart';
import '../infra/session_storage.dart';
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

  bool get isLoggedIn =>
      accessToken != null && apiCurrentUser != null && !needFirstAccess;
}

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw StateError('SessionStorage must be overridden in main()');
});

class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final storage = ref.read(sessionStorageProvider);
    final currentSessionData = await storage.loadSession();
    if (currentSessionData.token == null || currentSessionData.token!.isEmpty) {
      return const SessionState();
    }
    ref.read(apiClientProvider).setAccessToken(currentSessionData.token);
    ApiCurrentUser? user;
    if (currentSessionData.userJson != null &&
        currentSessionData.userJson!.isNotEmpty) {
      user = _getCurrentUserFromSession(user, currentSessionData);
    }
    _notifierCurrentUserId(storage, user);
    return SessionState(
      accessToken: currentSessionData.token,
      apiCurrentUser: user,
      needFirstAccess: currentSessionData.needFirstAccess,
    );
  }

  void _notifierCurrentUserId(SessionStorage storage, ApiCurrentUser? user) {
    final savedUserId = storage.getCurrentUserId();
    if (savedUserId != null && savedUserId.isNotEmpty) {
      ref.read(currentUserIdProvider.notifier).setCurrentUserId(savedUserId);
    } else if (user != null) {
      ref
          .read(currentUserIdProvider.notifier)
          .setCurrentUserId(user.id.toString());
    }
  }

  ApiCurrentUser? _getCurrentUserFromSession(
    ApiCurrentUser? user,
    ({bool needFirstAccess, String? token, String? userJson})
    currentSessionData,
  ) {
    try {
      user = ApiCurrentUser.fromJson(
        jsonDecode(currentSessionData.userJson!) as Map<String, dynamic>,
      );
    } catch (_) {
      user = null;
    }
    return user;
  }

  Future<void> _persistSession() async {
    final state = this.state.valueOrNull;
    if (state == null || state.accessToken == null) return;
    final storage = ref.read(sessionStorageProvider);
    await storage.saveSession(
      accessToken: state.accessToken!,
      userJson: state.apiCurrentUser != null
          ? jsonEncode(state.apiCurrentUser!.toJson())
          : null,
      needFirstAccess: state.needFirstAccess,
    );
  }

  Future<void> login(String email, String password) async {
    LoginResult loginResult = await _login(email, password);
    try {
      await _getCurrentUser(loginResult);
    } on ApiException catch (e) {
      await _handleGetCurrentUserErrors(e, loginResult);
    }
  }

  Future<void> _handleGetCurrentUserErrors(
    ApiException e,
    LoginResult loginResult,
  ) async {
    if (e.code == ApiConstants.codeUserNotFound) {
      state = AsyncData(
        SessionState(
          accessToken: loginResult.accessToken,
          needFirstAccess: true,
        ),
      );
      await _persistSession();
    } else {
      throw e;
    }
  }

  Future<void> _getCurrentUser(LoginResult loginResult) async {
    final user = await ref.read(userProvider.notifier).getCurrentUser();
    ref.read(currentUserIdProvider.notifier)
        .setCurrentUserId(user.id.toString());
    state = AsyncData(
      SessionState(
        accessToken: loginResult.accessToken,
        apiCurrentUser: user,
        needFirstAccess: false,
      ),
    );
    await _persistSession();
    await ref.read(sessionStorageProvider).setCurrentUserId(user.id.toString());
  }

  Future<LoginResult> _login(String email, String password) async {
    final loginResult = await ref
        .read(authProvider.notifier)
        .login(email, password);
    ref.read(apiClientProvider).setAccessToken(loginResult.accessToken);
    return loginResult;
  }

  Future<void> completeFirstAccess({
    required String name,
    required String phone,
    required String familyName,
  }) async {
    ApiCurrentUser user = await _completeFirstAccess(name, phone, familyName);
    state = AsyncData(
      SessionState(
        accessToken: state.valueOrNull?.accessToken,
        apiCurrentUser: user,
        needFirstAccess: false,
      ),
    );
    ref.read(currentUserIdProvider.notifier)
        .setCurrentUserId(user.id.toString());
    await _persistSession();
    await ref.read(sessionStorageProvider).setCurrentUserId(user.id.toString());
  }

  Future<ApiCurrentUser> _completeFirstAccess(String name, String phone, String familyName) async {
    final userNotifier = ref.read(userProvider.notifier);
    await userNotifier.createCurrentUser(
      name: name,
      phone: phone,
      familyName: familyName,
    );
    final user = await userNotifier.getCurrentUser();
    return user;
  }

  Future<void> logout() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.clearSession();
    ref.read(apiClientProvider).setAccessToken(null);
    ref.read(currentUserIdProvider.notifier).setCurrentUserId('');
    state = const AsyncData(SessionState());
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
