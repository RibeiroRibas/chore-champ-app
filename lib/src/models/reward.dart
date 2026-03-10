class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.achievementId,
    required this.claimedBy,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String achievementId;
  final List<String> claimedBy;

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    String? achievementId,
    List<String>? claimedBy,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      achievementId: achievementId ?? this.achievementId,
      claimedBy: claimedBy ?? this.claimedBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'achievementId': achievementId,
        'claimedBy': claimedBy,
      };

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      achievementId: json['achievementId'] as String,
      claimedBy: (json['claimedBy'] as List<dynamic>).cast<String>(),
    );
  }
}
