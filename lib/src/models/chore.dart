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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'points': points,
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'completed': completed,
      };

  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      points: (json['points'] as num).toInt(),
      assignedTo: json['assignedTo'] as String?,
      createdBy: json['createdBy'] as String,
      completed: json['completed'] as bool,
    );
  }

  /// Resposta da API (snake_case, ids numéricos).
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
}
