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
  });

  final String id;
  final String title;
  final String emoji;
  final int points;
  final String? assignedTo;
  final String createdBy;
  final bool completed;

  Chore copyWith({
    String? id,
    String? title,
    String? emoji,
    int? points,
    String? assignedTo,
    String? createdBy,
    bool? completed,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      points: points ?? this.points,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      completed: completed ?? this.completed,
    );
  }

  factory Chore.fromApiJson(Map<String, dynamic> json) {
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
    );
  }

  bool canEdit( FamilyMember currentUser) =>
      currentUser.role == Role.admin || createdBy == currentUser.id;

  bool canDelete(FamilyMember currentUser) =>
      currentUser.role == Role.admin || createdBy == currentUser.id;

  bool canAssignToMe(FamilyMember currentUser) =>
      !completed && !canRemoveAssignment(currentUser) && (currentUser.role == Role.admin || assignedTo == null);

  bool canRemoveAssignment(FamilyMember currentUser) =>
      !completed &&
          assignedTo != null &&
          (currentUser.role == Role.admin || assignedTo == currentUser.id);

  /// Botão "Concluir": só aparece se a tarefa estiver atribuída e (admin ou current user é o responsável).
  bool canComplete(FamilyMember currentUser) =>
      !completed &&
          assignedTo != null &&
          (currentUser.role == Role.admin || assignedTo == currentUser.id);
}
