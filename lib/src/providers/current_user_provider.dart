import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_provider.dart';

class CurrentUserIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setCurrentUserId(String id) {
    state = id;
  }

  Future<void> persist(String id) async {
    state = id;
    await ref.read(sessionStorageProvider).setCurrentUserId(id);
  }
}

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String>(
  CurrentUserIdNotifier.new,
);
