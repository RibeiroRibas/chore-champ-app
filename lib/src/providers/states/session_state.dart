import 'package:chore_champ_app/src/models/api_current_user.dart';

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
