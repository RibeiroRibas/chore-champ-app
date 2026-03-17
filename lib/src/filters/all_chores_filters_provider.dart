import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/filters/all_chores_filters.dart';

class AllChoresFiltersNotifier extends Notifier<AllChoresFilters> {
  @override
  AllChoresFilters build() => const AllChoresFilters();

  void setTitle(String value) => state = state.copyWith(title: value);
  void setRecurring(bool value) => state = state.copyWith(isRecurring: value);
  void setCompleted(bool value) => state = state.copyWith(completed: value);
  void setAssignedToUserId(String? value) => state = AllChoresFilters(
    title: state.title,
    isRecurring: state.isRecurring,
    completed: state.completed,
    assignedToUserId: value,
    page: state.page,
    pageSize: state.pageSize,
  );
}

final allChoresFiltersProvider =
    NotifierProvider<AllChoresFiltersNotifier, AllChoresFilters>(
      AllChoresFiltersNotifier.new,
    );
