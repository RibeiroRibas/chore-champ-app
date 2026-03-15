import 'dart:convert';

import 'package:chore_champ_app/src/providers/states/session_state.dart';
import 'package:chore_champ_app/src/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/constants/api_constants.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/infra/session_storage.dart';
import 'package:chore_champ_app/src/models/api_current_user.dart';
import 'package:chore_champ_app/src/models/refresh_token_model.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:chore_champ_app/src/providers/current_user_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/providers/rewards_provider.dart';
import 'package:chore_champ_app/src/providers/repositories_provider.dart';
import 'package:chore_champ_app/src/providers/auth_provider.dart';
import 'package:chore_champ_app/src/providers/user_provider.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw StateError('SessionStorage must be overridden in main()');
});

class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final storage = ref.read(sessionStorageProvider);
    RefreshTokenModel currentSessionData = await storage.loadSession();

    if (!currentSessionData.hasToken()) {
      return const SessionState();
    }

    final apiClient = ref.read(apiClientProvider);

    if (currentSessionData.isTokenExpired()) {
      final refreshToken = storage.getRefreshToken();
      final currentUserIdStr = storage.getCurrentUserId();

      if (refreshToken == null ||
          refreshToken.isEmpty ||
          currentUserIdStr == null ||
          currentUserIdStr.isEmpty) {
        await storage.clearSession();
        return const SessionState();
      }

      final currentUserId = int.tryParse(currentUserIdStr);
      if (currentUserId == null) {
        await storage.clearSession();
        return const SessionState();
      }

      try {
        final authRepository = ref.read(authRepositoryProvider);
        final refreshResult = await authRepository.refreshToken(
          refreshToken: refreshToken,
          currentUserId: currentUserId,
        );
        await storage.setRefreshToken(refreshResult.refreshToken);
        apiClient.setAccessToken(refreshResult.accessToken);
        currentSessionData = currentSessionData.copyWith(
          accessToken: refreshResult.accessToken,
        );
      } on ApiException {
        await storage.clearSession();
        return const SessionState();
      }
    } else {
      apiClient.setAccessToken(currentSessionData.accessToken);
    }

    ApiCurrentUser? user;
    if (currentSessionData.hasUserJson()) {
      user = _getCurrentUserFromSession(user, currentSessionData);
    }
    _notifierCurrentUserId(storage, user);
    return SessionState(
      accessToken: currentSessionData.accessToken,
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
    RefreshTokenModel currentSessionData,
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
    _invalidateFamilyScopedProviders();
  }

  Future<LoginResult> _login(String email, String password) async {
    final loginResult = await ref
        .read(authProvider.notifier)
        .login(email, password);
    ref.read(apiClientProvider).setAccessToken(loginResult.accessToken);
    await ref.read(sessionStorageProvider).setRefreshToken(loginResult.refreshToken);
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
    _invalidateFamilyScopedProviders();
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

  void _invalidateFamilyScopedProviders() {
    ref.invalidate(choresProvider);
    ref.invalidate(membersProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(rewardsProvider);
    ref.invalidate(currentMemberProvider);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
