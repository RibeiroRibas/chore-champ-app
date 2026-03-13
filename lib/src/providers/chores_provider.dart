import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore.dart';
import 'repositories_provider.dart';
import 'members_provider.dart';

class ChoresNotifier extends AsyncNotifier<List<Chore>> {
  @override
  Future<List<Chore>> build() =>
      ref.read(choreRepositoryProvider).fetchChores();

  Future<void> toggleComplete(String choreId) async {
    final list = state.valueOrNull;
    if (list == null) return;
    Chore? chore;
    try {
      chore = list.firstWhere((c) => c.id == choreId);
    } catch (_) {
      return;
    }
    final repo = ref.read(choreRepositoryProvider);
    final updated = await repo.updateChore(chore.copyWith(completed: !chore.completed));
    final newList = list.map((c) => c.id == choreId ? updated : c).toList();
    ref.invalidate(membersProvider);
    state = AsyncData(newList);
  }

  Future<void> assignChore(String choreId, String memberId) async {
    final list = state.valueOrNull;
    if (list == null) return;
    final i = list.indexWhere((c) => c.id == choreId);
    if (i < 0) return;
    final repo = ref.read(choreRepositoryProvider);
    final updated = await repo.updateChore(list[i].copyWith(assignedTo: memberId));
    final newList = List<Chore>.from(list)..[i] = updated;
    state = AsyncData(newList);
  }

  Future<void> addChore(Chore chore) async {
    final repo = ref.read(choreRepositoryProvider);
    final created = await repo.addChore(chore);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> deleteChore(String choreId) async {
    final repo = ref.read(choreRepositoryProvider);
    await repo.deleteChore(choreId);
    state = AsyncData(await repo.fetchChores());
  }
}

final choresProvider = AsyncNotifierProvider<ChoresNotifier, List<Chore>>(ChoresNotifier.new);
