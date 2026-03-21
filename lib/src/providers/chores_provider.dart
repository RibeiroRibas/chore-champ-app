import 'package:chore_champ_app/src/filters/all_chores_filters_provider.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/paginated_chores_response.dart';
import 'package:chore_champ_app/src/providers/rewards_provider.dart';
import 'package:chore_champ_app/src/providers/states/chores_state.dart';
import 'package:chore_champ_app/src/repositories/chore_repository.dart';
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
    ref.read(allChoresFiltersProvider.notifier).setPage(1);
    state = AsyncData(
      ChoresState(
        today: current.today,
        allPaginated: const AsyncLoading(),
        isLoadingMoreAllChores: false,
      ),
    );
    try {
      final filters = ref.read(allChoresFiltersProvider);
      final repo = ref.read(choreRepositoryProvider);
      final resp = await repo.fetchAllChores(filters);
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(
            today: updated.today,
            allPaginated: AsyncData(resp),
            isLoadingMoreAllChores: false,
          ),
        );
      }
    } catch (e, st) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(
            today: updated.today,
            allPaginated: AsyncError(e, st),
            isLoadingMoreAllChores: false,
          ),
        );
      }
    }
  }

  Future<void> loadNextPageAllChores() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMoreAllChores) return;

    final paginatedAsync = current.allPaginated;
    if (paginatedAsync.isLoading) return;

    final paginated = paginatedAsync.valueOrNull;
    if (paginated == null) return;
    if (paginated.totalPages == 0 || paginated.page >= paginated.totalPages) {
      return;
    }

    state = AsyncData(
      ChoresState(
        today: current.today,
        allPaginated: paginatedAsync,
        isLoadingMoreAllChores: true,
      ),
    );

    try {
      final nextPage = paginated.page + 1;
      final filters =
          ref.read(allChoresFiltersProvider).copyWith(page: nextPage);
      final repo = ref.read(choreRepositoryProvider);
      final resp = await repo.fetchAllChores(filters);

      ref.read(allChoresFiltersProvider.notifier).setPage(resp.page);

      final merged = PaginatedChoresResponse(
        items: [...paginated.items, ...resp.items],
        totalItems: resp.totalItems,
        page: resp.page,
        pageSize: resp.pageSize,
        totalPages: resp.totalPages,
      );

      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(
            today: updated.today,
            allPaginated: AsyncData(merged),
            isLoadingMoreAllChores: false,
          ),
        );
      }
    } catch (_) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData(
          ChoresState(
            today: updated.today,
            allPaginated: updated.allPaginated,
            isLoadingMoreAllChores: false,
          ),
        );
      }
    }
  }

  Future<bool> toggleComplete(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return false;
    Chore? chore;
    try {
      chore = list.firstWhere((c) => c.id == choreId);
    } catch (_) {
      return false;
    }
    final newCompletedValue = !chore.completed;

    final repo = ref.read(choreRepositoryProvider);
    final unlocked = await repo.updateChore(
      chore.copyWith(
        completed: newCompletedValue,
      ),
    );
    ref.invalidate(membersProvider);

    if (newCompletedValue) {
      _invalidateRankingRewardsAndMember();
    }
    await _refreshTodayAndAllChoresIfLoaded(repo);
    return unlocked;
  }

  Future<void> assignChore(String choreId, String memberId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final i = list.indexWhere((c) => c.id == choreId);
    if (i < 0) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.updateChore(list[i].copyWith(assignedTo: memberId));
    await _refreshTodayOnly(repo);
  }

  Future<bool> addChore(Chore chore) async {
    final repo = ref.read(choreRepositoryProvider);
    final unlocked = await repo.addChore(chore);
    await _refreshTodayAndAllChores(repo);
    _invalidateRankingRewardsAndMember();
    return unlocked;
  }

  Future<bool> updateChore(Chore chore) async {
    final repo = ref.read(choreRepositoryProvider);
    final unlocked = await repo.updateChore(chore);
    await _refreshTodayAndAllChoresIfLoaded(repo);
    _invalidateRankingRewardsAndMember();
    return unlocked;
  }

  Future<void> assignChoreToMe(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.assignChoreToMe(choreId);
    await _refreshTodayAndAllChores(repo);
    _invalidateRankingRewardsAndMember();
  }

  Future<void> removeAssignChoreToMe(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return;
    final repo = ref.read(choreRepositoryProvider);
    await repo.removeAssignChoreToMe(choreId);
    await _refreshTodayAndAllChores(repo);
    _invalidateRankingRewardsAndMember();
  }

  Future<bool> completeChore(String choreId) async {
    final current = state.valueOrNull;
    final list = current?.today.valueOrNull;
    if (list == null) return false;
    final repo = ref.read(choreRepositoryProvider);
    final unlocked = await repo.completeChore(choreId);
    await _refreshTodayAndAllChoresIfLoaded(repo);
    _invalidateRankingRewardsAndMember();
    return unlocked;
  }

  Future<void> deleteChore(String choreId) async {
    final repo = ref.read(choreRepositoryProvider);
    await repo.deleteChore(choreId);
    await _refreshTodayOnly(repo);
    _invalidateRankingRewardsAndMember();
  }

  Future<void> _refreshTodayOnly(ChoreRepository repo) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final newList = await repo.fetchTodayChores();
    state = AsyncData(
      ChoresState(
        today: AsyncData(newList),
        allPaginated: current.allPaginated,
        isLoadingMoreAllChores: current.isLoadingMoreAllChores,
      ),
    );
  }

  Future<void> _refreshTodayAndAllChores(ChoreRepository repo) async {
    ref.read(allChoresFiltersProvider.notifier).setPage(1);
    final filters = ref.read(allChoresFiltersProvider);
    final results = await Future.wait([
      repo.fetchTodayChores(),
      repo.fetchAllChores(filters),
    ]);
    state = AsyncData(
      ChoresState(
        today: AsyncData(results[0] as List<Chore>),
        allPaginated: AsyncData(results[1] as PaginatedChoresResponse),
        isLoadingMoreAllChores: false,
      ),
    );
  }

  Future<void> _refreshTodayAndAllChoresIfLoaded(ChoreRepository repo) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final hasAllData = current.allPaginated.valueOrNull != null;
    if (hasAllData) {
      await _refreshTodayAndAllChores(repo);
    } else {
      await _refreshTodayOnly(repo);
    }
  }


  void _invalidateRankingRewardsAndMember() {
    ref.invalidate(familyRankingProvider);
    ref.invalidate(currentMemberProvider);
    ref.invalidate(rewardsProvider);
  }
}

final choresProvider = AsyncNotifierProvider<ChoresNotifier, ChoresState>(
  ChoresNotifier.new,
);
