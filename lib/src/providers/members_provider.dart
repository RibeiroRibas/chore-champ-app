import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/models/family_member.dart';
import 'repositories_provider.dart';

class MembersNotifier extends AsyncNotifier<List<FamilyMember>> {
  @override
  Future<List<FamilyMember>> build() =>
      ref.read(memberRepositoryProvider).fetchMembers();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(memberRepositoryProvider).fetchMembers(),
    );
  }

  Future<void> addMember({required FamilyMember member}) async {
    final repo = ref.read(memberRepositoryProvider);
    final created = await repo.addMember(member: member);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateMember(FamilyMember member) async {
    final repo = ref.read(memberRepositoryProvider);
    final updated = await repo.updateMember(member);
    final list = state.value ?? [];
    state = AsyncData([...list.map((m) => m.id == member.id ? updated : m)]);
  }

  Future<void> deleteMember(String memberId) async {
    final repo = ref.read(memberRepositoryProvider);
    await repo.deleteMember(memberId);
    final list = state.value ?? [];
    state = AsyncData(list.where((m) => m.id != memberId).toList());
  }

  Future<void> resendPassword(String memberId) async {
    final repo = ref.read(memberRepositoryProvider);
    await repo.resendPassword(memberId);
  }

  Future<void> getMember(int memberId) async {
    final repo = ref.read(memberRepositoryProvider);
    await repo.fetchMember(memberId);
  }
}

final membersProvider =
    AsyncNotifierProvider<MembersNotifier, List<FamilyMember>>(
      MembersNotifier.new,
    );
