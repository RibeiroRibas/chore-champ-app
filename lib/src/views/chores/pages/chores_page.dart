import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/views/widgets/confirm_delete_dialog.dart';
import 'package:chore_champ_app/src/views/widgets/gradient_warm.dart';
import 'package:chore_champ_app/src/views/chores/components/chore_form_dialog_component.dart';
import 'package:chore_champ_app/src/views/chores/components/chore_card_component.dart';

enum ChoreFilter { all, mine, unassigned }

class ChoresPage extends ConsumerStatefulWidget {
  const ChoresPage({super.key});

  @override
  ConsumerState<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends ConsumerState<ChoresPage> {
  final _choreFormKey = GlobalKey<FormState>();
  ChoreFilter _filter = ChoreFilter.all;
  bool _showChoreForm = false;
  Chore? _editingChore;
  String? _deleteChoreId;
  Chore? _choreToRemoveAssignment;
  Chore? _choreToComplete;

  static String _getMemberName(String? id, List<FamilyMember> members) {
    if (id == null) return AppStrings.unassigned;
    try {
      return members.firstWhere((m) => m.id == id).getFirstName();
    } catch (_) {
      return 'Unknown';
    }
  }

  void _handleSaveChore(Chore chore) {
    if (chore.id.isNotEmpty) {
      ref.read(choresProvider.notifier).updateChore(chore);
    } else {
      ref.read(choresProvider.notifier).addChore(chore);
    }
    setState(() {
      _showChoreForm = false;
      _editingChore = null;
    });
  }

  Future<void> _handleAssignToMe(Chore chore) async {
    try {
      await ref.read(choresProvider.notifier).assignChoreToMe(chore.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleRemoveAssignment(Chore chore) async {
    try {
      await ref.read(choresProvider.notifier).removeAssignChoreToMe(chore.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleComplete(Chore chore) async {
    try {
      await ref.read(choresProvider.notifier).completeChore(chore.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleDeleteChore() async {
    if (_deleteChoreId == null) return;
    final id = _deleteChoreId!;
    try {
      await ref.read(choresProvider.notifier).deleteChore(id);
      if (!mounted) return;
      setState(() => _deleteChoreId = null);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
      setState(() => _deleteChoreId = null);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
      setState(() => _deleteChoreId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = ref.watch(currentMemberProvider);
    final choresAsync = ref.watch(choresProvider);
    final membersAsync = ref.watch(membersProvider);

    return currentMember.when(
      data: (currentMember) {
     return choresAsync.when(
      data: (chores) {
        List<Chore> filtered = getFilteredChores(chores, currentMember);
        final pending = filtered.where((c) => !c.completed).toList();
        final completed = filtered.where((c) => c.completed).toList();
        return membersAsync.when(
          data: (members) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.chores, style: Theme.of(context).textTheme.titleLarge),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() {
                                _editingChore = null;
                                _showChoreForm = true;
                              }),
                          borderRadius: BorderRadius.circular(24),
                          child: GradientWarm(
                            borderRadius: BorderRadius.circular(24),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.add, color: AppColors.primaryForeground, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ChoreFilter.values.map((f) {
                      final label = f == ChoreFilter.all
                          ? AppStrings.filterAll
                          : f == ChoreFilter.mine
                              ? AppStrings.filterMine
                              : AppStrings.unassigned;
                      final active = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: active,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: active ? AppColors.primaryForeground : AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ...pending.map(
                    (chore) => ChoreCardComponent(
                      chore: chore,
                      assignedToName: _getMemberName(chore.assignedTo, members),
                      completed: false,
                      onToggle: () => ref.read(choresProvider.notifier).toggleComplete(chore.id),
                      onEdit: chore.canEdit(currentMember)
                          ? () => setState(() {
                                _editingChore = chore;
                                _showChoreForm = true;
                              })
                          : null,
                      onAssignToMe: chore.canAssignToMe(currentMember)
                          ? () => _handleAssignToMe(chore)
                          : null,
                      onRemoveAssignment: chore.canRemoveAssignment(currentMember)
                          ? () => setState(() => _choreToRemoveAssignment = chore)
                          : null,
                      onComplete: chore.canComplete(currentMember)
                          ? () => setState(() => _choreToComplete = chore)
                          : null,
                      onDelete: chore.canDelete(currentMember)
                          ? () => setState(() => _deleteChoreId = chore.id)
                          : null,
                      showEdit: chore.canEdit(currentMember),
                      showAssignToMe: chore.canAssignToMe(currentMember),
                      showRemoveAssignment: chore.canRemoveAssignment(currentMember),
                      showComplete: chore.canComplete(currentMember),
                      showDelete: chore.canDelete(currentMember),
                    ),
                  ),
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.completed,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 8),
                    ...completed.map(
                      (chore) => ChoreCardComponent(
                        chore: chore,
                        assignedToName: _getMemberName(chore.assignedTo, members),
                        completed: true,
                        onToggle: () => ref.read(choresProvider.notifier).toggleComplete(chore.id),
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
                if (_showChoreForm)
                  ChoreFormDialogComponent(
                    formKey: _choreFormKey,
                    chore: _editingChore,
                    currentMember: currentMember,
                    onCancel: () => setState(() {
                      _showChoreForm = false;
                      _editingChore = null;
                    }),
                    onSave: _handleSaveChore,
                  ),
                if (_deleteChoreId != null)
                  ConfirmDeleteDialog(
                    title: AppStrings.deleteChore,
                    description: AppStrings.deleteChoreDescription,
                    onCancel: () => setState(() => _deleteChoreId = null),
                    onConfirm: _handleDeleteChore,
                  ),
                if (_choreToRemoveAssignment != null)
                  ConfirmDeleteDialog(
                    title: AppStrings.confirmRemoveAssignmentTitle,
                    description: AppStrings.confirmRemoveAssignmentDescription,
                    confirmLabel: AppStrings.removeAssignment,
                    confirmButtonDestructive: false,
                    onCancel: () => setState(() => _choreToRemoveAssignment = null),
                    onConfirm: () async {
                      final chore = _choreToRemoveAssignment!;
                      setState(() => _choreToRemoveAssignment = null);
                      await _handleRemoveAssignment(chore);
                    },
                  ),
                if (_choreToComplete != null)
                  ConfirmDeleteDialog(
                    title: AppStrings.confirmCompleteChoreTitle,
                    description: AppStrings.confirmCompleteChoreDescription,
                    confirmLabel: AppStrings.completeButton,
                    confirmButtonDestructive: false,
                    onCancel: () => setState(() => _choreToComplete = null),
                    onConfirm: () async {
                      final chore = _choreToComplete!;
                      setState(() => _choreToComplete = null);
                      await _handleComplete(chore);
                    },
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
    );
    },
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
  );

  }

  List<Chore> getFilteredChores(List<Chore> chores, FamilyMember currentMember) {
    List<Chore> filtered;
    switch (_filter) {
      case ChoreFilter.mine:
        filtered = chores.where((c) => c.assignedTo == currentMember.id).toList();
        break;
      case ChoreFilter.unassigned:
        filtered = chores.where((c) => c.assignedTo == null).toList();
        break;
      case ChoreFilter.all:
        filtered = List.from(chores);
    }
    return filtered;
  }
}
