import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';
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

  Future<void> addMember({
    required String name,
    required String email,
    required String phone,
    required int roleId,
    String? avatar,
  }) async {
    final repo = ref.read(memberRepositoryProvider);
    final created = await repo.addMember(
      name: name,
      email: email,
      phone: phone,
      roleId: roleId,
      avatar: avatar,
    );
    state = AsyncData([...?state.value, created]);
  }

  Future<void> updateMember(
    String memberId, {
    required String name,
    required String email,
    required String phone,
    required int roleId,
    String? avatar,
  }) async {
    final repo = ref.read(memberRepositoryProvider);
    final updated = await repo.updateMember(
      memberId,
      name: name,
      email: email,
      phone: phone,
      roleId: roleId,
      avatar: avatar,
    );
    final list = state.value ?? [];
    state = AsyncData([...list.map((m) => m.id == memberId ? updated : m)]);
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
}

final membersProvider =
    AsyncNotifierProvider<MembersNotifier, List<FamilyMember>>(
      MembersNotifier.new,
    );
