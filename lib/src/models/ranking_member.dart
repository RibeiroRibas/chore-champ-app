class RankingMember {
  const RankingMember({
    required this.id,
    required this.name,
    required this.points,
    required this.roleName,
    this.avatar = '👤',
  });

  final int id;
  final String name;
  final int points;
  final String roleName;
  final String avatar;

  factory RankingMember.fromJson(Map<String, dynamic> json) {
    final avatarRaw = json['avatar'];
    final avatar = (avatarRaw is String && avatarRaw.isNotEmpty)
        ? avatarRaw
        : '👤';
    return RankingMember(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      roleName: json['role_name'] as String? ?? '',
      avatar: avatar,
    );
  }
}
