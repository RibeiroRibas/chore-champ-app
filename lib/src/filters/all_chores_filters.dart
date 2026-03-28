class _AssigneeIdUnspecified {
  const _AssigneeIdUnspecified();
}

const _assigneeIdUnspecified = _AssigneeIdUnspecified();

class AllChoresFilters {
  const AllChoresFilters({
    this.title = '',
    this.isRecurring = false,
    this.completed = false,
    this.assignedToUserId,
    this.page = 1,
    this.pageSize = 20,
  });

  final String title;
  final bool isRecurring;
  final bool completed;
  final String? assignedToUserId;
  final int page;
  final int pageSize;

  bool get showAllChores => !isRecurring && !completed;

  AllChoresFilters copyWith({
    String? title,
    bool? isRecurring,
    bool? completed,
    Object? assignedToUserId = _assigneeIdUnspecified,
    int? page,
    int? pageSize,
  }) {
    return AllChoresFilters(
      title: title ?? this.title,
      isRecurring: isRecurring ?? this.isRecurring,
      completed: completed ?? this.completed,
      assignedToUserId: identical(assignedToUserId, _assigneeIdUnspecified)
          ? this.assignedToUserId
          : assignedToUserId as String?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
