import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories_provider.dart';

class CurrentMemberNotifier extends AsyncNotifier<FamilyMember> {
  @override
  Future<FamilyMember> build() async {
    final userId = ref.watch(currentUserIdProvider);
    final member = await ref.read(memberRepositoryProvider).fetchMember(int.parse(userId));
    try {
      final currentUser = await ref.read(userRepositoryProvider).getCurrentUser();
      return member.copyWith(points: currentUser.availablePoints);
    } catch (_) {
      return member;
    }
  }
}

final currentMemberProvider =
    AsyncNotifierProvider<CurrentMemberNotifier, FamilyMember>(
      CurrentMemberNotifier.new,
    );
