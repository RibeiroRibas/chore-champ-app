import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_contants.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/day_of_week.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/providers/repositories_provider.dart';
import 'package:chore_champ_app/src/views/components/rounded_dropdown_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChoreFormDialogComponent extends ConsumerStatefulWidget {
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
  ConsumerState<ChoreFormDialogComponent> createState() =>
      _ChoreFormDialogComponentState();
}

class _ChoreFormDialogComponentState
    extends ConsumerState<ChoreFormDialogComponent> {
  late String _title;
  late String _emoji;
  late int _points;
  String? _assignedToUserId;
  late bool _completed;
  late bool _isRecurring;
  late List<int> _selectedDayIds;

  bool get _isEdit => widget.chore != null;

  @override
  void initState() {
    super.initState();
    if (widget.chore != null) {
      _title = widget.chore!.title;
      _emoji = widget.chore!.emoji;
      _points = widget.chore!.points;
      _assignedToUserId = widget.chore!.assignedTo;
      _completed = widget.chore!.completed;
      _isRecurring = widget.chore!.isRecurring;
      _selectedDayIds = List<int>.from(widget.chore!.recurrenceDayIds);
    } else {
      _title = '';
      _emoji = '🧹';
      _points = 10;
      _assignedToUserId = widget.currentMember.isAdmin()
          ? null
          : widget.currentMember.id;
      _completed = false;
      _isRecurring = false;
      _selectedDayIds = [];
    }
  }

  bool get _isValid =>
      _title.trim().isNotEmpty &&
      _points >= 1 &&
      _emoji.trim().isNotEmpty &&
      (!_isRecurring || _selectedDayIds.isNotEmpty);

  String _memberFirstName(List<FamilyMember> members, String? userId) {
    if (userId == null) return AppStrings.unassigned;
    try {
      return members.firstWhere((m) => m.id == userId).getFirstName();
    } catch (_) {
      return AppStrings.unknownMember;
    }
  }

  void _toggleDay(int dayId) {
    setState(() {
      if (_selectedDayIds.contains(dayId)) {
        _selectedDayIds.remove(dayId);
      } else {
        _selectedDayIds.add(dayId);
        _selectedDayIds.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysAsync = ref.watch(daysOfWeekProvider);

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
                    decoration: const InputDecoration(hintText: '10'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) {
                        return 'Informe pontos (mín. 1).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.assigneeLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  ref.watch(membersProvider).when(
                    data: (members) =>
                        widget.currentMember.isAdmin()
                        ? SizedBox(
                            height: 50,
                            child: RoundedDropdownComponent<String?>(
                              value: _assignedToUserId,
                              labelText: null,
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
                              onChanged: (value) =>
                                  setState(() => _assignedToUserId = value),
                            ),
                          )
                        : _isEdit
                        ? InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _memberFirstName(
                                members,
                                widget.chore!.assignedTo,
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  widget.currentMember.getFirstName(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, _) => Text(
                      AppStrings.errorGeneric,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v ?? false),
                    title: const Text(AppStrings.recurringChoreLabel),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _completed,
                    onChanged: (v) => setState(() => _completed = v ?? false),
                    title: const Text(AppStrings.completed),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.selectRecurrenceDays,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    daysAsync.when(
                      data: (days) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: days.map((DayOfWeek day) {
                          final selected = _selectedDayIds.contains(day.id);
                          return FilterChip(
                            label: Text(day.name),
                            selected: selected,
                            onSelected: (_) => _toggleDay(day.id),
                            selectedColor: AppColors.primary,
                            checkmarkColor: AppColors.primaryForeground,
                          );
                        }).toList(),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, _) => Text(
                        AppStrings.errorGeneric,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    if (_isRecurring && _selectedDayIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Selecione ao menos um dia.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
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
    final days = ref.read(daysOfWeekProvider).valueOrNull ?? [];
    final recurrenceDays = _selectedDayIds
        .map((id) => days.firstWhere((d) => d.id == id))
        .toList();

    if (_isEdit) {
      return widget.chore!.copyWith(
        title: _title.trim(),
        emoji: _emoji.trim().isEmpty ? '🧹' : _emoji.trim(),
        points: _points,
        assignedTo: _assignedToUserId,
        completed: _completed,
        isRecurring: _isRecurring,
        recurrenceDays: recurrenceDays,
      );
    }
    return Chore(
      id: '',
      title: _title.trim(),
      emoji: _emoji.trim().isEmpty ? '🧹' : _emoji.trim(),
      points: _points,
      assignedTo: _assignedToUserId,
      createdBy: widget.currentMember.id,
      completed: _completed,
      isRecurring: _isRecurring,
      recurrenceDays: recurrenceDays,
    );
  }
}
