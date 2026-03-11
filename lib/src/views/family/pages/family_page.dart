import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../infra/api_error_presentation.dart';
import '../../../models/family_member.dart';
import '../../../providers/achievements_provider.dart';
import '../../../providers/chores_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/members_provider.dart';
import '../components/admin_required_message_component.dart';
import '../components/delete_member_dialog_component.dart';
import '../components/member_card_component.dart';
import '../components/member_form_dialog_component.dart' show MemberFormDialogComponent, formatPhoneDisplay;

class FamilyPage extends ConsumerStatefulWidget {
  const FamilyPage({super.key});

  @override
  ConsumerState<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends ConsumerState<FamilyPage> {
  final _memberFormKey = GlobalKey<FormState>();
  bool _dialogOpen = false;
  FamilyMember? _editingMember;
  String? _deleteId;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _avatar = '👩';
  Role _role = Role.collaborator;
  bool _resendPasswordLoading = false;

  void _openCreate() {
    setState(() {
      _editingMember = null;
      _name = '';
      _email = '';
      _phone = '';
      _avatar = '👩';
      _role = Role.collaborator;
      _dialogOpen = true;
    });
  }

  void _openEdit(FamilyMember member) {
    setState(() {
      _editingMember = member;
      _name = member.name;
      _email = member.email ?? '';
      _phone = formatPhoneDisplay(member.phoneNumber ?? '');
      _avatar = member.avatar;
      _role = member.role;
      _dialogOpen = true;
    });
  }

  Future<void> _handleSave() async {
    if (_name.trim().isEmpty || _email.trim().isEmpty || _phone.trim().isEmpty) return;
    final phoneDigits = _phone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 10 || phoneDigits.length > 11) return;
    try {
      if (_editingMember != null) {
        await ref.read(membersProvider.notifier).updateMember(
              _editingMember!.id,
              name: _name.trim(),
              email: _email.trim(),
              phone: phoneDigits,
              roleId: FamilyMember.roleIdFromRole(_role),
              avatar: _avatar,
            );
      } else {
        await ref.read(membersProvider.notifier).addMember(
              name: _name.trim(),
              email: _email.trim(),
              phone: phoneDigits,
              roleId: FamilyMember.roleIdFromRole(_role),
              avatar: _avatar,
            );
      }
      if (!mounted) return;
      setState(() => _dialogOpen = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleResendPassword() async {
    if (_editingMember == null) return;
    setState(() => _resendPasswordLoading = true);
    try {
      await ref.read(membersProvider.notifier).resendPassword(_editingMember!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resendPasswordSent)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    } finally {
      if (mounted) setState(() => _resendPasswordLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_deleteId == null) return;
    final id = _deleteId!;
    try {
      await ref.read(membersProvider.notifier).deleteMember(id);
      if (!mounted) return;
      setState(() => _deleteId = null);
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
      setState(() => _deleteId = null); // fecha o dialog mesmo com erro para não travar
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
      setState(() => _deleteId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final membersAsync = ref.watch(membersProvider);
    final choresAsync = ref.watch(choresProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser.role != Role.admin) {
      return const AdminRequiredMessageComponent();
    }

    return membersAsync.when(
      data: (members) {
        return choresAsync.when(
          data: (chores) {
            return achievementsAsync.when(
              data: (achievements) {
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
                              Text(
                                AppStrings.familyMembers,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton.icon(
                                onPressed: _openCreate,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(AppStrings.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (members.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 48),
                                child: Text(
                                  '${AppStrings.noMembersYet} ${AppStrings.createFirstMember}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ...members.map((member) {
                              final memberChores =
                                  chores.where((c) => c.assignedTo == member.id).toList();
                              final completedChores =
                                  memberChores.where((c) => c.completed).length;
                              final unlockedAchievements = achievements
                                  .where((a) => a.unlockedBy.contains(member.id))
                                  .length;
                              return MemberCardComponent(
                                member: member,
                                tasksCount: memberChores.length,
                                completedCount: completedChores,
                                achievementsCount: unlockedAchievements,
                                isAdmin: true,
                                onEdit: () => _openEdit(member),
                                onDelete: () => setState(() => _deleteId = member.id),
                              );
                            }),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    if (_dialogOpen)
                      MemberFormDialogComponent(
                        formKey: _memberFormKey,
                        isEditing: _editingMember != null,
                        name: _name,
                        email: _email,
                        phone: _phone,
                        avatar: _avatar,
                        role: _role,
                        onNameChanged: (v) => setState(() => _name = v),
                        onEmailChanged: (v) => setState(() => _email = v),
                        onPhoneChanged: (v) => setState(() => _phone = v),
                        onAvatarChanged: (v) => setState(() => _avatar = v),
                        onRoleChanged: (v) => setState(() => _role = v),
                        onCancel: () => setState(() => _dialogOpen = false),
                        onSave: _handleSave,
                        onResendPassword: _editingMember != null ? _handleResendPassword : null,
                        canSave: _name.trim().isNotEmpty &&
                            _email.trim().isNotEmpty &&
                            _phone.trim().isNotEmpty,
                        resendPasswordLoading: _resendPasswordLoading,
                      ),
                    if (_deleteId != null)
                      DeleteMemberDialogComponent(
                        onCancel: () => setState(() => _deleteId = null),
                        onConfirm: _handleDelete,
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildMembersErrorWidget(context, e, ref),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildMembersErrorWidget(context, e, ref),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildMembersErrorWidget(context, e, ref),
    );
  }

  Widget _buildMembersErrorWidget(BuildContext context, Object? error, WidgetRef ref) {
    final theme = Theme.of(context);
    final String message;
    final int? code;
    if (error is ApiException) {
      message = messageForApiCode(error.code);
      code = error.code;
    } else {
      message = defaultApiErrorMessage;
      code = null;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Código: $code',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(membersProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
