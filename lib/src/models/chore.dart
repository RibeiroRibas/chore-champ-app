class Chore {
  const Chore({
    required this.id,
    required this.title,
    required this.emoji,
    required this.points,
    required this.assignedTo,
    required this.createdBy,
    required this.completed,
    required this.category,
  });

  final String id;
  final String title;
  final String emoji;
  final int points;
  final String? assignedTo;
  final String createdBy;
  final bool completed;
  final String category;

  Chore copyWith({
    String? id,
    String? title,
    String? emoji,
    int? points,
    String? assignedTo,
    String? createdBy,
    bool? completed,
    String? category,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      points: points ?? this.points,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      completed: completed ?? this.completed,
      category: category ?? this.category,
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
        'category': category,
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
      category: json['category'] as String,
    );
  }
}
