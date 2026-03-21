import 'package:chore_champ_app/src/models/day_of_week.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/models/role.dart';

class Chore {
  const Chore({
    required this.id,
    required this.title,
    required this.emoji,
    required this.points,
    required this.assignedTo,
    required this.createdBy,
    required this.completed,
    this.isRecurring = false,
    this.recurrenceDays = const [],
  });

  final String id;
  final String title;
  final String emoji;
  final int points;
  final String? assignedTo;
  final String createdBy;
  final bool completed;
  final bool isRecurring;

  final List<DayOfWeek> recurrenceDays;

  List<int> get recurrenceDayIds =>
      recurrenceDays.map((d) => d.id).toList();

  Chore copyWith({
    String? id,
    String? title,
    String? emoji,
    int? points,
    String? assignedTo,
    String? createdBy,
    bool? completed,
    bool? isRecurring,
    List<DayOfWeek>? recurrenceDays,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      points: points ?? this.points,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      completed: completed ?? this.completed,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
    );
  }

  factory Chore.fromApiJson(Map<String, dynamic> json) {
    List<DayOfWeek> recurrenceDays = const [];
    final rawDays = json['recurrence_days'];
    if (rawDays is List) {
      recurrenceDays = rawDays
          .map((e) => DayOfWeek.fromApiJson(e as Map<String, dynamic>))
          .toList();
    }

    return Chore(
      id: (json['id'] as num).toString(),
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      points: (json['points'] as num).toInt(),
      assignedTo: json['assigned_to'] != null
          ? (json['assigned_to'] as num).toString()
          : null,
      createdBy: (json['created_by'] as num).toString(),
      completed: json['completed'] as bool,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceDays: recurrenceDays,
    );
  }

  bool canEdit(FamilyMember currentUser) =>
      currentUser.role == Role.admin || createdBy == currentUser.id;

  bool canDelete(FamilyMember currentUser) =>
      currentUser.role == Role.admin || createdBy == currentUser.id;

  bool canAssignToMe(FamilyMember currentUser) =>
      !completed &&
      !canRemoveAssignment(currentUser) &&
      (currentUser.role == Role.admin || assignedTo == null);

  bool canRemoveAssignment(FamilyMember currentUser) =>
      !completed &&
      assignedTo != null &&
      currentUser.role == Role.admin;

  bool canComplete(
    FamilyMember currentUser, {
    required List<Chore> todayChores,
  }) {
    if (completed || assignedTo == null) return false;
    if (currentUser.role == Role.admin) return true;
    if (assignedTo != currentUser.id) return false;
    return todayChores.any((c) => c.id == id);
  }
}
