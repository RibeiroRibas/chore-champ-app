import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';
import 'members_provider.dart';
import 'repositories_provider.dart';

class CurrentUserIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setCurrentUserId(String id) {
    state = id;
  }

  Future<void> loadFromAuth() async {
    final auth = ref.read(authRepositoryProvider);
    // final id = await auth.getCurrentUserId();
    // if (id != null) state = id;
  }

  Future<void> persist(String id) async {
    final auth = ref.read(authRepositoryProvider);
    // await auth.setCurrentUserId(id);
    state = id;
  }
}

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String>(CurrentUserIdNotifier.new);

final currentUserProvider = Provider<FamilyMember?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final membersAsync = ref.watch(membersProvider);
  return membersAsync.when(
    data: (members) {
      try {
        return members.firstWhere((m) => m.id == userId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
