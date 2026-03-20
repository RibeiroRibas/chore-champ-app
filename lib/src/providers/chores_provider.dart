import 'package:chore_champ_app/src/filters/all_chores_filters_provider.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/paginated_chores_response.dart';
import 'package:chore_champ_app/src/providers/rewards_provider.dart';
import 'package:chore_champ_app/src/providers/states/chores_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'current_member_provider.dart';
import 'members_provider.dart';
import 'repositories_provider.dart';
import 'family_ranking_provider.dart';

class ChoresNotifier extends AsyncNotifier<ChoresState> {
  @override
  Future<ChoresState> build() async {
    final list = await ref.read(choreRepositoryProvider).fetchTodayChores();
    return ChoresState(
      today: AsyncData(list),
      allPaginated: const AsyncData(null),
    );
  }

  Future<void> loadAllChores() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      ChoresState(today: current.today, allPaginated: const AsyncLoading()),
    );
    try {
      final filters = ref.read(allChoresFiltersProvider);
      final repo = ref.read(choreRepositoryProvider);
      final resp = await repo.fetchAllChores(filters);
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(today: updated.today, allPaginated: AsyncData(resp)),
        );
      }
    } catch (e, st) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(today: updated.today, allPaginated: AsyncError(e, st)),
        );
      }
    }
  }

  Future<void> toggleComplete(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    Chore? chore;
    try {
      chore = list.firstWhere((c) => c.id == choreId);
    } catch (_) {
      return;
    }
    final newCompletedValue = !chore.completed;

    final repo = ref.read(choreRepositoryProvider);
    await repo.updateChore(
      chore.copyWith(
        completed: newCompletedValue,
      ),
    );
    ref.invalidate(membersProvider);

    if (newCompletedValue) {
      ref.invalidate(familyRankingProvider);
      ref.invalidate(currentMemberProvider);
      ref.invalidate(rewardsProvider);
    }

    final newList = await repo.fetchTodayChores();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current!.allPaginated,
      ),
    );
  }

  Future<void> assignChore(String choreId, String memberId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final i = list.indexWhere((c) => c.id == choreId);
    if (i < 0) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.updateChore(list[i].copyWith(assignedTo: memberId));
    final newList = await repo.fetchTodayChores();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current!.allPaginated,
      ),
    );
  }

  Future<void> addChore(Chore chore) async {
    final repo = ref.read(choreRepositoryProvider);
    await repo.addChore(chore);
    final filters = ref.read(allChoresFiltersProvider);
    final results = await Future.wait([
      repo.fetchTodayChores(),
      repo.fetchAllChores(filters),
    ]);
    state = AsyncData(
      ChoresState(
        today: AsyncData(results[0] as List<Chore>),
        allPaginated: AsyncData(results[1] as PaginatedChoresResponse),
      ),
    );

    ref.invalidate(familyRankingProvider);
    ref.invalidate(currentMemberProvider);
    ref.invalidate(rewardsProvider);
  }

  Future<void> updateChore(Chore chore) async {
    final current = state.valueOrNull;
    final repo = ref.read(choreRepositoryProvider);
    await repo.updateChore(chore);
    final newList = await repo.fetchTodayChores();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current!.allPaginated,
      ),
    );

    ref.invalidate(familyRankingProvider);
    ref.invalidate(currentMemberProvider);
    ref.invalidate(rewardsProvider);
  }

  Future<void> assignChoreToMe(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.assignChoreToMe(choreId);
    final filters = ref.read(allChoresFiltersProvider);
    final results = await Future.wait([
      repo.fetchTodayChores(),
      repo.fetchAllChores(filters),
    ]);
    state = AsyncData(
      ChoresState(
        today: AsyncData(results[0] as List<Chore>),
        allPaginated: AsyncData(results[1] as PaginatedChoresResponse),
      ),
    );
  }

  Future<void> removeAssignChoreToMe(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.removeAssignChoreToMe(choreId);
    final filters = ref.read(allChoresFiltersProvider);
    final results = await Future.wait([
      repo.fetchTodayChores(),
      repo.fetchAllChores(filters),
    ]);
    state = AsyncData(
      ChoresState(
        today: AsyncData(results[0] as List<Chore>),
        allPaginated: AsyncData(results[1] as PaginatedChoresResponse),
      ),
    );
  }

  Future<void> completeChore(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final repo = ref.read(choreRepositoryProvider);
    final updated = await repo.completeChore(choreId);
    final newList = list.map((c) => c.id == choreId ? updated : c).toList();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current!.allPaginated,
      ),
    );

    ref.invalidate(familyRankingProvider);
    ref.invalidate(currentMemberProvider);
    ref.invalidate(rewardsProvider);
  }

  Future<void> deleteChore(String choreId) async {
    final current = state.valueOrNull;
    final repo = ref.read(choreRepositoryProvider);
    await repo.deleteChore(choreId);
    final newList = await repo.fetchTodayChores();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current!.allPaginated,
      ),
    );
  }
}

final choresProvider = AsyncNotifierProvider<ChoresNotifier, ChoresState>(
  ChoresNotifier.new,
);
