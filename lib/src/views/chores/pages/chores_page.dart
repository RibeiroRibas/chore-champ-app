import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/chore.dart';
import '../../../models/family_member.dart';
import '../../../providers/chores_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/members_provider.dart';
import '../components/add_chore_form_component.dart';
import '../components/chore_row_component.dart';
import '../../widgets/gradient_warm.dart';

enum ChoreFilter { all, mine, unassigned }

class ChoresPage extends ConsumerStatefulWidget {
  const ChoresPage({super.key});

  @override
  ConsumerState<ChoresPage> createState() => _ChoresPageState();
}

class _ChoresPageState extends ConsumerState<ChoresPage> {
  ChoreFilter _filter = ChoreFilter.all;
  bool _showAdd = false;
  final _titleController = TextEditingController();
  final _emojiController = TextEditingController(text: '🧹');
  final _pointsController = TextEditingController(text: '10');
  final _categoryController = TextEditingController(text: 'Geral');

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    _pointsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  static String _getMemberName(String? id, List<FamilyMember> members) {
    if (id == null) return AppStrings.unassigned;
    try {
      return members.firstWhere((m) => m.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  static bool _canDelete(Chore chore, FamilyMember currentUser) =>
      currentUser.role == Role.admin || chore.createdBy == currentUser.id;

  static bool _canAssignSelf(Chore chore, FamilyMember currentUser) =>
      chore.assignedTo == null && (currentUser.role == Role.admin || currentUser.role == Role.collaborator);

  void _handleAdd(FamilyMember currentUser) {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final points = int.tryParse(_pointsController.text) ?? 10;
    ref.read(choresProvider.notifier).addChore(Chore(
          id: '',
          title: title,
          emoji: _emojiController.text.isNotEmpty ? _emojiController.text : '🧹',
          points: points,
          assignedTo: currentUser.role == Role.collaborator ? currentUser.id : null,
          createdBy: currentUser.id,
          completed: false,
          category: _categoryController.text.trim().isEmpty ? 'Geral' : _categoryController.text.trim(),
        ));
    _titleController.clear();
    _emojiController.text = '🧹';
    _pointsController.text = '10';
    _categoryController.text = 'Geral';
    setState(() => _showAdd = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final choresAsync = ref.watch(choresProvider);
    final membersAsync = ref.watch(membersProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return choresAsync.when(
      data: (chores) {
        List<Chore> filtered;
        switch (_filter) {
          case ChoreFilter.mine:
            filtered = chores.where((c) => c.assignedTo == currentUser.id).toList();
            break;
          case ChoreFilter.unassigned:
            filtered = chores.where((c) => c.assignedTo == null).toList();
            break;
          case ChoreFilter.all:
          default:
            filtered = List.from(chores);
        }
        final pending = filtered.where((c) => !c.completed).toList();
        final completed = filtered.where((c) => c.completed).toList();

        return membersAsync.when(
          data: (members) {
            return SingleChildScrollView(
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
                          onTap: () => setState(() => _showAdd = !_showAdd),
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
                  if (_showAdd) ...[
                    const SizedBox(height: 16),
                    AddChoreFormComponent(
                      emojiController: _emojiController,
                      titleController: _titleController,
                      pointsController: _pointsController,
                      categoryController: _categoryController,
                      onSubmit: () => _handleAdd(currentUser),
                    ),
                  ],
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
                    (chore) => ChoreRowComponent(
                      chore: chore,
                      assignedToName: _getMemberName(chore.assignedTo, members),
                      completed: false,
                      onToggle: () => ref.read(choresProvider.notifier).toggleComplete(chore.id),
                      onClaim: _canAssignSelf(chore, currentUser)
                          ? () => ref.read(choresProvider.notifier).assignChore(chore.id, currentUser.id)
                          : null,
                      onDelete: _canDelete(chore, currentUser)
                          ? () => ref.read(choresProvider.notifier).deleteChore(chore.id)
                          : null,
                      showClaim: _canAssignSelf(chore, currentUser),
                      showDelete: _canDelete(chore, currentUser),
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
                      (chore) => ChoreRowComponent(
                        chore: chore,
                        assignedToName: _getMemberName(chore.assignedTo, members),
                        completed: true,
                        onToggle: () => ref.read(choresProvider.notifier).toggleComplete(chore.id),
                        showClaim: false,
                        showDelete: false,
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
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
}
