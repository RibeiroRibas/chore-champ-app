class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredPoints,
    required this.unlockedBy,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredPoints;
  final List<String> unlockedBy;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    int? requiredPoints,
    List<String>? unlockedBy,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      unlockedBy: unlockedBy ?? this.unlockedBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'requiredPoints': requiredPoints,
        'unlockedBy': unlockedBy,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      requiredPoints: (json['requiredPoints'] as num).toInt(),
      unlockedBy: (json['unlockedBy'] as List<dynamic>).cast<String>(),
    );
  }
}
