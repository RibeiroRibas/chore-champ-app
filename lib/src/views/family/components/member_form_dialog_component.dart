import 'package:chore_champ_app/src/constants/app_contants.dart';
import 'package:chore_champ_app/src/helpers/phone.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:flutter/material.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/role.dart';

class MemberFormDialogComponent extends StatefulWidget {
  const MemberFormDialogComponent({
    super.key,
    required this.formKey,
    this.member,
    required this.onCancel,
    required this.onSave,
    this.onResendPassword,
    this.resendPasswordLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final FamilyMember? member;
  final VoidCallback onCancel;
  final Function(FamilyMember familyMember) onSave;
  final VoidCallback? onResendPassword;
  final bool resendPasswordLoading;

  @override
  State<MemberFormDialogComponent> createState() =>
      _MemberFormDialogComponentState();
}

class _MemberFormDialogComponentState extends State<MemberFormDialogComponent> {
  FamilyMember member = FamilyMember.build();

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      setState(() {
        member = widget.member!;
      });
    }
  }

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
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    member.isIdPresent()
                        ? AppStrings.editMember
                        : AppStrings.newMember,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.nameLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: member.name,
                    onChanged: (v) => member = member.copyWith(name: v.trim()),
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: AppStrings.nameHint,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o nome.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.email,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: member.email,
                    onChanged: (v) => setState(
                      () => member = member.copyWith(email: v.trim()),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: AppStrings.emailHint,
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Informe o e-mail.';
                      if (!emailRegex.hasMatch(value)) {
                        return AppStrings.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.phone,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: member.phoneNumber,
                    onChanged: (v) => setState(
                      () => member = member.copyWith(phoneNumber: v.trim()),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneInputFormatter()],
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
                  Text(
                    AppStrings.avatar,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: avatarOptions.map((e) {
                      final selected = member.avatar == e;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => member = member.copyWith(avatar: e)),
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
                  Text(
                    AppStrings.roleLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Role>(
                    initialValue: member.role,
                    decoration: const InputDecoration(),
                    items: Role.values
                        .map(
                          (r) => DropdownMenuItem<Role>(
                            value: r,
                            child: Text(r.labelPortuguese),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => member = member.copyWith(role: v));
                      }
                    },
                  ),
                  if (member.isIdPresent() &&
                      widget.onResendPassword != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: widget.resendPasswordLoading
                            ? null
                            : widget.onResendPassword,
                        icon: widget.resendPasswordLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                        onPressed: widget.onCancel,
                        child: const Text(AppStrings.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: member.isPresent()
                            ? () {
                                if (widget.formKey.currentState?.validate() ==
                                    true) {
                                  widget.onSave(member);
                                }
                              }
                            : null,
                        child: Text(
                          member.isPresent()
                              ? AppStrings.saveChanges
                              : AppStrings.createMember,
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
