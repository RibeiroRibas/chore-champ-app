import 'package:chore_champ_app/src/models/api_current_user.dart';
import 'package:chore_champ_app/src/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories_provider.dart';

class UserNotifier extends Notifier<void> {
  @override
  void build() {}

  UserRepository get _user => ref.read(userRepositoryProvider);

  Future<ApiCurrentUser> getCurrentUser() async {
    return _user.getCurrentUser();
  }

  Future<void> createCurrentUser({
    required String name,
    required String phone,
    required String familyName,
  }) async {
    await _user.createCurrentUser(
      name: name,
      phone: phone,
      familyName: familyName,
    );
  }
}

final userProvider = NotifierProvider<UserNotifier, void>(UserNotifier.new);
