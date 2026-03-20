import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/filters/all_chores_filters.dart';

class AllChoresFiltersNotifier extends Notifier<AllChoresFilters> {
  @override
  AllChoresFilters build() => const AllChoresFilters();

  void setTitle(String value) =>
      state = state.copyWith(title: value, page: 1);
  void setRecurring(bool value) =>
      state = state.copyWith(isRecurring: value, page: 1);
  void setCompleted(bool value) =>
      state = state.copyWith(completed: value, page: 1);
  void setAssignedToUserId(String? value) => state = AllChoresFilters(
    title: state.title,
    isRecurring: state.isRecurring,
    completed: state.completed,
    assignedToUserId: value,
    page: 1,
    pageSize: state.pageSize,
  );

  void setPage(int page) => state = state.copyWith(page: page);
}

final allChoresFiltersProvider =
    NotifierProvider<AllChoresFiltersNotifier, AllChoresFilters>(
      AllChoresFiltersNotifier.new,
    );
