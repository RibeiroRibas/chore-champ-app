import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/family_member.dart';

const _avatarOptions = ['👩', '👨', '👧', '🧒', '👶', '👴', '👵', '🧑', '👦', '🦸', '🧙'];

class MemberFormDialogComponent extends StatelessWidget {
  const MemberFormDialogComponent({
    super.key,
    required this.isEditing,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onAvatarChanged,
    required this.onRoleChanged,
    required this.onCancel,
    required this.onSave,
    this.onResendPassword,
    required this.canSave,
    this.resendPasswordLoading = false,
  });

  final bool isEditing;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final Role role;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onAvatarChanged;
  final ValueChanged<Role> onRoleChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onResendPassword;
  final bool canSave;
  final bool resendPasswordLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? AppStrings.editMember : AppStrings.newMember,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(AppStrings.nameLabel, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: name,
                  onChanged: onNameChanged,
                  decoration: const InputDecoration(
                    hintText: AppStrings.nameHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.email, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: email,
                  onChanged: onEmailChanged,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: AppStrings.emailHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.phone, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: phone,
                  onChanged: onPhoneChanged,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: AppStrings.phoneHint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.avatar, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _avatarOptions.map((e) {
                    final selected = avatar == e;
                    return GestureDetector(
                      onTap: () => onAvatarChanged(e),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.roleLabel, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<Role>(
                  value: role,
                  decoration: const InputDecoration(),
                  items: Role.values
                      .map((r) => DropdownMenuItem<Role>(
                            value: r,
                            child: Text(r.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onRoleChanged(v);
                  },
                ),
                if (isEditing && onResendPassword != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: resendPasswordLoading ? null : onResendPassword,
                      icon: resendPasswordLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.email_outlined, size: 18),
                      label: const Text(AppStrings.resendPassword),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text(AppStrings.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: canSave ? onSave : null,
                      child: Text(
                        isEditing ? AppStrings.saveChanges : AppStrings.createMember,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
