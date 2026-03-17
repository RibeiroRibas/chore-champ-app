class AllChoresFilters {
  const AllChoresFilters({
    this.title = '',
    this.isRecurring = false,
    this.completed = false,
    this.assignedToUserId,
    this.page = 1,
    this.pageSize = 50,
  });

  final String title;
  final bool isRecurring;
  final bool completed;
  final String? assignedToUserId;
  final int page;
  final int pageSize;

  AllChoresFilters copyWith({
    String? title,
    bool? isRecurring,
    bool? completed,
    String? assignedToUserId,
    int? page,
    int? pageSize,
  }) {
    return AllChoresFilters(
      title: title ?? this.title,
      isRecurring: isRecurring ?? this.isRecurring,
      completed: completed ?? this.completed,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
