class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredPoints,
    required this.acquiredTimes,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredPoints;
  final int acquiredTimes;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    int? requiredPoints,
    int? acquiredTimes,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      acquiredTimes: acquiredTimes ?? this.acquiredTimes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'requiredPoints': requiredPoints,
    'acquiredTimes': acquiredTimes,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: (json['id'] as num).toInt().toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      requiredPoints: (json['required_points'] as num? ?? json['requiredPoints'] as num).toInt(),
      acquiredTimes: (json['acquired_times'] as num?)?.toInt() ?? 0,
    );
  }
}
