import 'package:chore_champ_app/src/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'repositories_provider.dart';

class CurrentMemberNotifier extends AsyncNotifier<FamilyMember> {
  @override
  Future<FamilyMember> build() {
    final userId = ref.watch(currentUserIdProvider);
    return ref.read(memberRepositoryProvider).fetchMember(int.parse(userId));
  }
}

final currentMemberProvider =
AsyncNotifierProvider<CurrentMemberNotifier, FamilyMember>(
  CurrentMemberNotifier.new,
);