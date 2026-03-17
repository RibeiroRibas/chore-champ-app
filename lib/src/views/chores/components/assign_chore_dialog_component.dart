import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/views/components/rounded_dropdown_component.dart';
import 'package:flutter/material.dart';

class AssignChoreDialogComponent extends StatelessWidget {
  const AssignChoreDialogComponent({
    super.key,
    required this.chore,
    required this.members,
    required this.selectedMemberId,
    required this.onSelectedChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  final Chore chore;
  final List<FamilyMember> members;
  final String? selectedMemberId;
  final ValueChanged<String?> onSelectedChanged;
  final VoidCallback onCancel;
  final void Function(String? memberId) onConfirm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
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
                AppStrings.assignChoreTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                chore.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: RoundedDropdownComponent<String?>(
                  value: selectedMemberId,
                  labelText: AppStrings.assigneeLabel,
                  hint: AppStrings.unassigned,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(AppStrings.unassigned),
                    ),
                    ...members.map(
                      (m) => DropdownMenuItem<String?>(
                        value: m.id,
                        child: Text(m.getFirstName()),
                      ),
                    ),
                  ],
                  onChanged: onSelectedChanged,
                ),
              ),
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
                    onPressed: () => onConfirm(selectedMemberId),
                    child: const Text(AppStrings.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
