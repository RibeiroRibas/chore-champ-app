import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/infra/success_snackbar.dart';
import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/filters/all_chores_filters_provider.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:chore_champ_app/src/views/chores/components/chore_card_component.dart';
import 'package:chore_champ_app/src/views/chores/components/chore_form_dialog_component.dart';
import 'package:chore_champ_app/src/views/components/rounded_dropdown_component.dart';
import 'package:chore_champ_app/src/views/components/confirm_action_dialog.dart';
import 'package:chore_champ_app/src/views/components/gradient_warm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChoresTab { today, all }

enum TodayFilter { mine, all }

class ChoresPage extends ConsumerStatefulWidget {
  const ChoresPage({super.key});

  @override
  ConsumerState<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends ConsumerState<ChoresPage> {
  final _choreFormKey = GlobalKey<FormState>();
  ChoresTab _tab = ChoresTab.today;
  TodayFilter _todayFilter = TodayFilter.mine;
  bool _showChoreForm = false;
  Chore? _editingChore;
  String? _deleteChoreId;
  Chore? _choreToRemoveAssignment;
  Chore? _choreToComplete;

  final TextEditingController _titleController = TextEditingController();

  static String _getMemberName(String? id, List<FamilyMember> members) {
    if (id == null) return AppStrings.unassigned;
    try {
      return members.firstWhere((m) => m.id == id).getFirstName();
    } catch (_) {
      return AppStrings.unknownMember;
    }
  }

  Future<void> _handleSaveChore(Chore chore) async {
    try {
      if (chore.id.isNotEmpty) {
        await ref.read(choresProvider.notifier).updateChore(chore);
      } else {
        await ref.read(choresProvider.notifier).addChore(chore);
      }
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        message: chore.id.isNotEmpty
            ? AppStrings.choreUpdated
            : AppStrings.choreCreated,
      );
      setState(() {
        _showChoreForm = false;
        _editingChore = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleAssignToMe(Chore chore) async {
    try {
      await ref.read(choresProvider.notifier).assignChoreToMe(chore.id);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        message: AppStrings.choreAssignedToMeSuccess,
        icon: const Text('😊', style: TextStyle(fontSize: 22)),
      );
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
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        message: AppStrings.choreUnassignedSuccess,
        icon: const Text('😢', style: TextStyle(fontSize: 22)),
      );
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
      if (!mounted) return;
      showSuccessSnackBar(context, message: AppStrings.choreCompletedSuccess);
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
      if (_tab == ChoresTab.all) {
        ref.read(choresProvider.notifier).loadAllChores();
      }
      showSuccessSnackBar(context, message: AppStrings.choreDeletedSuccess);
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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _loadAllChoresWithCurrentFilters() {
    ref.read(allChoresFiltersProvider.notifier).setTitle(_titleController.text);
    ref.read(choresProvider.notifier).loadAllChores();
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = ref.watch(currentMemberProvider);
    final choresAsync = ref.watch(choresProvider);
    final allChoresFilters = ref.watch(allChoresFiltersProvider);

    return currentMember.when(
      data: (currentMember) {
        return choresAsync.when(
          data: (choresState) {
            final membersAsync = ref.watch(membersProvider);
            final todayList = choresState.today.valueOrNull ?? <Chore>[];
            final todayChores = _getTodayFilteredChores(
              todayList,
              currentMember,
            );
            final allChores =
                choresState.allPaginated.valueOrNull?.items ?? <Chore>[];
            final sourceChores = _tab == ChoresTab.today
                ? todayChores
                : allChores;
            final pending = sourceChores.where((c) => !c.completed).toList();
            final completed = sourceChores.where((c) => c.completed).toList();
            return membersAsync.when(
              data: (members) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.chores,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
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
                                      child: Icon(
                                        Icons.add,
                                        color: AppColors.primaryForeground,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text(AppStrings.filterToday),
                                selected: _tab == ChoresTab.today,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _tab == ChoresTab.today
                                      ? AppColors.primaryForeground
                                      : AppColors.mutedForeground,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() => _tab = ChoresTab.today);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text(AppStrings.filterAll),
                                selected: _tab == ChoresTab.all,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _tab == ChoresTab.all
                                      ? AppColors.primaryForeground
                                      : AppColors.mutedForeground,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() => _tab = ChoresTab.all);
                                  _loadAllChoresWithCurrentFilters();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_tab == ChoresTab.today) ...[
                            Row(
                              children: [
                                ChoiceChip(
                                  label: Text(AppStrings.filterMine),
                                  selected: _todayFilter == TodayFilter.mine,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _todayFilter == TodayFilter.mine
                                        ? AppColors.primaryForeground
                                        : AppColors.mutedForeground,
                                    fontSize: 12,
                                  ),
                                  onSelected: (_) {
                                    setState(
                                      () => _todayFilter = TodayFilter.mine,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: Text(AppStrings.filterAll),
                                  selected: _todayFilter == TodayFilter.all,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _todayFilter == TodayFilter.all
                                        ? AppColors.primaryForeground
                                        : AppColors.mutedForeground,
                                    fontSize: 12,
                                  ),
                                  onSelected: (_) {
                                    setState(
                                      () => _todayFilter = TodayFilter.all,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ] else ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    AppStrings.filtersTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _titleController,
                                        decoration: const InputDecoration(
                                          labelText: AppStrings.choreTitleLabel,
                                        ),
                                        onSubmitted: (_) =>
                                            _loadAllChoresWithCurrentFilters(),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: membersAsync.when(
                                        data: (members) {
                                          return SizedBox(
                                            height: 56,
                                            child: RoundedDropdownComponent<String?>(
                                              value: allChoresFilters
                                                  .assignedToUserId,
                                              labelText:
                                                  AppStrings.assigneeLabel,
                                              hint: AppStrings.selectHint,
                                              items: [
                                                const DropdownMenuItem<String?>(
                                                  value: null,
                                                  child: Text(
                                                    AppStrings.allAssignees,
                                                  ),
                                                ),
                                                ...members.map(
                                                  (m) =>
                                                      DropdownMenuItem<String?>(
                                                        value: m.id,
                                                        child: Text(
                                                          m.getFirstName(),
                                                        ),
                                                      ),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                ref
                                                    .read(
                                                      allChoresFiltersProvider
                                                          .notifier,
                                                    )
                                                    .setAssignedToUserId(value);
                                                _loadAllChoresWithCurrentFilters();
                                              },
                                            ),
                                          );
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: allChoresFilters.isRecurring,
                                  onChanged: (v) {
                                    ref
                                        .read(allChoresFiltersProvider.notifier)
                                        .setRecurring(v ?? false);
                                    _loadAllChoresWithCurrentFilters();
                                  },
                                ),
                                const Text(AppStrings.filterRecurring),
                                const SizedBox(width: 16),
                                Checkbox(
                                  value: allChoresFilters.completed,
                                  onChanged: (v) {
                                    ref
                                        .read(allChoresFiltersProvider.notifier)
                                        .setCompleted(v ?? false);
                                    _loadAllChoresWithCurrentFilters();
                                  },
                                ),
                                const Text(AppStrings.filterCompleted),
                              ],
                            ),
                            const SizedBox(height: 16),
                            choresState.allPaginated.when(
                              data: (_) => const SizedBox.shrink(),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, _) =>
                                  Center(child: Text(AppStrings.errorGeneric)),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ...pending.map(
                            (chore) => ChoreCardComponent(
                              chore: chore,
                              assignedToName: _getMemberName(
                                chore.assignedTo,
                                members,
                              ),
                              completed: false,
                              onToggle: () => ref
                                  .read(choresProvider.notifier)
                                  .toggleComplete(chore.id),
                              onEdit: chore.canEdit(currentMember)
                                  ? () => setState(() {
                                      _editingChore = chore;
                                      _showChoreForm = true;
                                    })
                                  : null,
                              onAssignToMe: chore.canAssignToMe(currentMember)
                                  ? () => _handleAssignToMe(chore)
                                  : null,
                              onRemoveAssignment:
                                  chore.canRemoveAssignment(currentMember)
                                  ? () => setState(
                                      () => _choreToRemoveAssignment = chore,
                                    )
                                  : null,
                              onComplete: chore.canComplete(currentMember)
                                  ? () =>
                                        setState(() => _choreToComplete = chore)
                                  : null,
                              onDelete: chore.canDelete(currentMember)
                                  ? () => setState(
                                      () => _deleteChoreId = chore.id,
                                    )
                                  : null,
                              showEdit: chore.canEdit(currentMember),
                              showAssignToMe: chore.canAssignToMe(
                                currentMember,
                              ),
                              showRemoveAssignment: chore.canRemoveAssignment(
                                currentMember,
                              ),
                              showComplete: chore.canComplete(currentMember),
                              showDelete: chore.canDelete(currentMember),
                            ),
                          ),
                          if (completed.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.completed,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: AppColors.mutedForeground),
                            ),
                            const SizedBox(height: 8),
                            ...completed.map(
                              (chore) => ChoreCardComponent(
                                chore: chore,
                                assignedToName: _getMemberName(
                                  chore.assignedTo,
                                  members,
                                ),
                                completed: true,
                                onToggle: () => ref
                                    .read(choresProvider.notifier)
                                    .toggleComplete(chore.id),
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
                      ConfirmActionDialog(
                        title: AppStrings.deleteChore,
                        description: AppStrings.deleteChoreDescription,
                        onCancel: () => setState(() => _deleteChoreId = null),
                        onConfirm: _handleDeleteChore,
                      ),
                    if (_choreToRemoveAssignment != null)
                      ConfirmActionDialog(
                        title: AppStrings.confirmRemoveAssignmentTitle,
                        description:
                            AppStrings.confirmRemoveAssignmentDescription,
                        confirmLabel: AppStrings.removeAssignment,
                        confirmButtonDestructive: false,
                        onCancel: () =>
                            setState(() => _choreToRemoveAssignment = null),
                        onConfirm: () async {
                          final chore = _choreToRemoveAssignment!;
                          setState(() => _choreToRemoveAssignment = null);
                          await _handleRemoveAssignment(chore);
                        },
                      ),
                    if (_choreToComplete != null)
                      ConfirmActionDialog(
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

  List<Chore> _getTodayFilteredChores(
    List<Chore> chores,
    FamilyMember currentMember,
  ) {
    switch (_todayFilter) {
      case TodayFilter.mine:
        return chores.where((c) => c.assignedTo == currentMember.id).toList();
      case TodayFilter.all:
        return List<Chore>.from(chores);
    }
  }
}
