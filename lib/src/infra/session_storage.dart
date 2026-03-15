import 'package:shared_preferences/shared_preferences.dart';

import 'package:chore_champ_app/src/models/refresh_token_model.dart';

const _keyAccessToken = 'session_access_token';
const _keyUserJson = 'session_user_json';
const _keyNeedFirstAccess = 'session_need_first_access';
const _keyCurrentUserId = 'session_current_user_id';
const _keyRefreshToken = 'session_refresh_token';

class SessionStorage {
  SessionStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveSession({
    required String accessToken,
    required String? userJson,
    required bool needFirstAccess,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    if (userJson != null) {
      await _prefs.setString(_keyUserJson, userJson);
    } else {
      await _prefs.remove(_keyUserJson);
    }
    await _prefs.setBool(_keyNeedFirstAccess, needFirstAccess);
  }

  Future<RefreshTokenModel> loadSession() async {
    final token = _prefs.getString(_keyAccessToken);
    final userJson = _prefs.getString(_keyUserJson);
    final needFirstAccess = _prefs.getBool(_keyNeedFirstAccess) ?? false;
    final refreshToken = _prefs.getString(_keyRefreshToken);
    return RefreshTokenModel(
      accessToken: token,
      refreshToken: refreshToken,
      userJson: userJson,
      needFirstAccess: needFirstAccess,
    );
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUserJson);
    await _prefs.remove(_keyNeedFirstAccess);
    await _prefs.remove(_keyCurrentUserId);
    await _prefs.remove(_keyRefreshToken);
  }

  String? getCurrentUserId() => _prefs.getString(_keyCurrentUserId);

  Future<void> setCurrentUserId(String id) async {
    if (id.isEmpty) {
      await _prefs.remove(_keyCurrentUserId);
    } else {
      await _prefs.setString(_keyCurrentUserId, id);
    }
  }

  String? getRefreshToken() => _prefs.getString(_keyRefreshToken);

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_keyRefreshToken);
    } else {
      await _prefs.setString(_keyRefreshToken, token);
    }
  }
}

