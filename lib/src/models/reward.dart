class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.achievementId,
    this.requiredPoints = 0,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String achievementId;
  final int requiredPoints;
  final bool unlocked;

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    String? achievementId,
    int? requiredPoints,
    bool? unlocked,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      achievementId: achievementId ?? this.achievementId,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'achievementId': achievementId,
    'requiredPoints': requiredPoints,
    'unlocked': unlocked,
  };

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: (json['id'] as num).toInt().toString(),
      title: json['title'] as String,
      description: (json['subtitle'] as String?) ?? '',
      emoji: json['emoji'] as String,
      achievementId: (json['achievement_id'] as num).toInt().toString(),
      requiredPoints: (json['required_points'] as num?)?.toInt() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}
