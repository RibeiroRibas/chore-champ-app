import 'package:chore_champ_app/src/models/api_current_user_family.dart';

class ApiCurrentUser {
  const ApiCurrentUser({
    required this.id,
    required this.name,
    required this.authId,
    required this.roleId,
    required this.roleName,
    required this.phoneNumber,
    required this.family,
  });

  final int id;
  final String name;
  final int authId;
  final int roleId;
  final String roleName;
  final String phoneNumber;
  final ApiCurrentUserFamily family;

  factory ApiCurrentUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>? ?? {};
    final familyJson = json['family'] as Map<String, dynamic>?;
    return ApiCurrentUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      authId: (json['auth_id'] as num).toInt(),
      roleId: (role['id'] as num?)?.toInt() ?? 0,
      roleName: role['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      family: familyJson != null
          ? ApiCurrentUserFamily.fromJson(familyJson)
          : ApiCurrentUserFamily(id: 0, name: ''),
    );
  }
}
