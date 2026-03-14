import 'package:chore_champ_app/src/constants/app_contants.dart';
import 'package:chore_champ_app/src/helpers/phone.dart';
import 'package:chore_champ_app/src/models/role.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    this.points = 0,
    required this.email,
    required this.phoneNumber,
  });

  final String id;
  final String name;
  final String avatar;
  final Role role;
  final int points;
  final String email;
  final String phoneNumber;

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

  int getRoleId() => role == Role.admin ? 1 : 2;

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
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
    );
  }

  factory FamilyMember.build() {
    return FamilyMember(
      id: '',
      name: '',
      avatar: '👩',
      role: Role.collaborator,
      email: '',
      phoneNumber: '',
    );
  }

  String getFirstName() {
    if (name.contains(' ')) {
      return name.split(' ')[0];
    }
    return name;
  }

  bool isAdmin() => role == Role.admin;

  bool isIdEmpty() => id.isEmpty;

  bool isIdPresent() => id.isNotEmpty;

  bool isPresent() => name.isNotEmpty && email.isNotEmpty && phoneNumber.isNotEmpty && isValidCellPhone(phoneNumber) && emailRegex.hasMatch(email);

}
