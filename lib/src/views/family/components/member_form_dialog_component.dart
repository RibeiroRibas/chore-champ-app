import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/role.dart';

const _avatarOptions = ['👩', '👨', '👧', '🧒', '👶', '👴', '👵', '🧑', '👦', '🦸', '🧙'];

final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

String formatPhoneDisplay(String? value) {
  if (value == null || value.isEmpty) return '';
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.length <= 2) return '($digits';
  if (digits.length <= 6) return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
  if (digits.length <= 10) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
  }
  return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
}

class _PhoneMaskInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = formatPhoneDisplay(limited.isEmpty ? '' : limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MemberFormDialogComponent extends StatelessWidget {
  const MemberFormDialogComponent({
    super.key,
    required this.formKey,
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

  final GlobalKey<FormState> formKey;
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
            child: Form(
              key: formKey,
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.email, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: email,
                    onChanged: onEmailChanged,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: AppStrings.emailHint,
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Informe o e-mail.';
                      if (!_emailRegex.hasMatch(value)) return AppStrings.invalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.phone, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: phone,
                    onChanged: onPhoneChanged,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_PhoneMaskInputFormatter()],
                    decoration: const InputDecoration(
                      hintText: AppStrings.phoneHint,
                    ),
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (digits.isEmpty) return 'Informe o telefone.';
                      if (digits.length < 10 || digits.length > 11) {
                        return AppStrings.invalidPhone;
                      }
                      return null;
                    },
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
                        onPressed: canSave
                            ? () {
                                if (formKey.currentState?.validate() == true) {
                                  onSave();
                                }
                              }
                            : null,
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
      ),
    );
  }
}
