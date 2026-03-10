import 'package:chore_champ_app/src/models/role.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    this.points = 0,
    this.email,
    this.phoneNumber,
  });

  final String id;
  final String name;
  final String avatar;
  final Role role;
  final int points;
  final String? email;
  final String? phoneNumber;

  FamilyMember copyWith({
    String? id,
    String? name,
    String? avatar,
    Role? role,
    int? points,
    String? email,
    String? phoneNumber,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      points: points ?? this.points,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  static Role roleFromRoleId(int roleId) {
    return roleId == 1 ? Role.admin : Role.collaborator;
  }

  static int roleIdFromRole(Role role) {
    return role == Role.admin ? 1 : 2;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'role': role.name,
        'points': points,
      };

  factory FamilyMember.fromApiJson(Map<String, dynamic> json) {
    final roleId = (json['role_id'] as num?)?.toInt() ?? 2;
    final avatarRaw = json['avatar'];
    final avatar = (avatarRaw is String && avatarRaw.isNotEmpty)
        ? avatarRaw
        : '👤';
    return FamilyMember(
      id: (json['id'] as num).toInt().toString(),
      name: json['name'] as String? ?? '',
      avatar: avatar,
      role: roleFromRoleId(roleId),
      points: 0,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('role_id') || json.containsKey('email')) {
      return FamilyMember.fromApiJson(json);
    }
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      role: Role.values.byName(json['role'] as String),
      points: (json['points'] as num).toInt(),
    );
  }
}
