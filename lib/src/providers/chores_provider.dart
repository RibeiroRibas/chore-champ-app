import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore.dart';
import '../models/family_member.dart';
import 'repositories_provider.dart';
import 'members_provider.dart';

class ChoresNotifier extends AsyncNotifier<List<Chore>> {
  @override
  Future<List<Chore>> build() =>
      ref.read(choreRepositoryProvider).fetchChores();

  Future<void> toggleComplete(String choreId) async {
    final repo = ref.read(choreRepositoryProvider);
    final memberRepo = ref.read(memberRepositoryProvider);
    final list = repo.chores;
    Chore? chore;
    try {
      chore = list.firstWhere((c) => c.id == choreId);
    } catch (_) {
      return;
    }
    final newCompleted = !chore.completed;
    if (chore.assignedTo != null) {
      FamilyMember? member;
      // try {
      //   member = memberRepo.members.firstWhere((m) => m.id == chore!.assignedTo);
      // } catch (_) {}
      // if (member != null) {
      //   final newPoints = newCompleted ? member.points + chore.points : (member.points - chore.points).clamp(0, 999999);
      //   final idx = memberRepo.members.indexWhere((m) => m.id == member!.id);
      //   if (idx >= 0) memberRepo.members[idx] = member.copyWith(points: newPoints);
      // }
    }
    final updated = chore.copyWith(completed: newCompleted);
    final i = list.indexWhere((c) => c.id == choreId);
    if (i >= 0) list[i] = updated;
    ref.invalidate(membersProvider);
    state = AsyncData(List.from(list));
  }

  Future<void> assignChore(String choreId, String memberId) async {
    final repo = ref.read(choreRepositoryProvider);
    final list = repo.chores;
    final i = list.indexWhere((c) => c.id == choreId);
    if (i < 0) return;
    list[i] = list[i].copyWith(assignedTo: memberId);
    state = AsyncData(List.from(list));
  }

  Future<void> addChore(Chore chore) async {
    final repo = ref.read(choreRepositoryProvider);
    final created = await repo.addChore(chore);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> deleteChore(String choreId) async {
    final repo = ref.read(choreRepositoryProvider);
    await repo.deleteChore(choreId);
    state = AsyncData(List.from(repo.chores));
  }
}

final choresProvider = AsyncNotifierProvider<ChoresNotifier, List<Chore>>(ChoresNotifier.new);
