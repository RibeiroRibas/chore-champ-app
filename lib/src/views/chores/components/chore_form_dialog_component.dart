import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_contants.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';


import 'package:chore_champ_app/src/constants/app_strings.dart';

class ChoreFormDialogComponent extends StatefulWidget {
  const ChoreFormDialogComponent({
    super.key,
    required this.formKey,
    this.chore,
    required this.currentMember,
    required this.onCancel,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final Chore? chore;
  final FamilyMember currentMember;
  final VoidCallback onCancel;
  final void Function(Chore chore) onSave;

  @override
  State<ChoreFormDialogComponent> createState() =>
      _ChoreFormDialogComponentState();
}

class _ChoreFormDialogComponentState extends State<ChoreFormDialogComponent> {
  late String _title;
  late String _emoji;
  late int _points;

  bool get _isEdit => widget.chore != null;

  @override
  void initState() {
    super.initState();
    if (widget.chore != null) {
      _title = widget.chore!.title;
      _emoji = widget.chore!.emoji;
      _points = widget.chore!.points;
    } else {
      _title = '';
      _emoji = '🧹';
      _points = 10;
    }
  }

  bool get _isValid =>
      _title.trim().isNotEmpty && _points >= 1 && _emoji.trim().isNotEmpty;

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
                    _isEdit ? AppStrings.editChore : AppStrings.newChore,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.choreTitleLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _title,
                    onChanged: (v) => setState(() => _title = v),
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: AppStrings.choreName,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o nome da tarefa.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.emoji,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: choreEmojiOptions.map((e) {
                      final selected = _emoji == e;
                      return GestureDetector(
                        onTap: () => setState(() => _emoji = e),
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
                    AppStrings.pointsLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _points.toString(),
                    onChanged: (v) {
                      int? n = int.tryParse(v);
                      if (v.isEmpty) n = 0;
                      if (n != null) setState(() => _points = n!);
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '10',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) {
                        return 'Informe pontos (mín. 1).';
                      }
                      return null;
                    },
                  ),
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
                        onPressed: _isValid
                            ? () {
                                if (widget.formKey.currentState?.validate() ==
                                    true) {
                                  widget.onSave(_buildChore());
                                }
                              }
                            : null,
                        child: Text(
                          _isEdit
                              ? AppStrings.saveChanges
                              : AppStrings.addChore,
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

  Chore _buildChore() {
    if (_isEdit) {
      return widget.chore!.copyWith(
        title: _title.trim(),
        emoji: _emoji.trim().isEmpty ? '🧹' : _emoji.trim(),
        points: _points,
      );
    }
    return Chore(
      id: '',
      title: _title.trim(),
      emoji: _emoji.trim().isEmpty ? '🧹' : _emoji.trim(),
      points: _points,
      assignedTo: widget.currentMember.role == Role.collaborator
          ? widget.currentMember.id
          : null,
      createdBy: widget.currentMember.id,
      completed: false,
    );
  }
}
