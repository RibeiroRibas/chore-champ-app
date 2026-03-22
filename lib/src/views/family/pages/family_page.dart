import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:chore_champ_app/src/providers/members_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/success_snackbar.dart';
import 'package:chore_champ_app/src/views/components/info_alert_dialog.dart';
import 'package:chore_champ_app/src/models/family_member.dart';
import 'package:chore_champ_app/src/models/ranking_member.dart';
import 'package:chore_champ_app/src/providers/achievements_provider.dart';
import 'package:chore_champ_app/src/providers/chores_provider.dart';
import 'package:chore_champ_app/src/providers/family_ranking_provider.dart';
import 'package:chore_champ_app/src/views/components/confirm_action_dialog.dart';
import 'package:chore_champ_app/src/views/components/gradient_warm.dart';
import 'package:chore_champ_app/src/views/family/components/member_card_component.dart';
import 'package:chore_champ_app/src/views/family/components/member_form_dialog_component.dart'
    show MemberFormDialogComponent;

class FamilyPage extends ConsumerStatefulWidget {
  const FamilyPage({super.key});

  @override
  ConsumerState<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends ConsumerState<FamilyPage> {
  final _memberFormKey = GlobalKey<FormState>();
  bool _dialogOpen = false;
  FamilyMember? member;
  String? _deleteId;
  bool _resendPasswordLoading = false;

  void _openCreate() {
    setState(() {
      member = null;
      _dialogOpen = true;
    });
  }

  void _openEdit(FamilyMember member) {
    setState(() {
      this.member = member;
      _dialogOpen = true;
    });
  }

  Future<void> _handleSave(FamilyMember member) async {
    try {
      final isCreate = !member.isIdPresent();
      if (member.isIdPresent()) {
        await ref.read(membersProvider.notifier).updateMember(member);
      } else {
        await ref.read(membersProvider.notifier).addMember(member: member);
      }
      if (!mounted) return;
      setState(() => _dialogOpen = false);
      if (isCreate) {
        await showInfoAlertDialog(
          context,
          title: AppStrings.memberCreatedPasswordEmailDialogTitle,
          message: AppStrings.memberCreatedPasswordEmailInfo,
          icon: Icons.mark_email_read_outlined,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleResendPassword() async {
    if (member == null) return;
    setState(() => _resendPasswordLoading = true);
    try {
      await ref.read(membersProvider.notifier).resendPassword(member!.id);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        message: AppStrings.resendPasswordSent,
        icon: Icon(
          Icons.mark_email_read_outlined,
          color: AppColors.primary,
          size: 22,
        ),
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
      setState(() => _deleteId = null);
    } catch (_) {
      if (!mounted) return;
      showGenericErrorSnackBar(context);
      setState(() => _deleteId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = ref.watch(currentMemberProvider);
    final membersAsync = ref.watch(membersProvider);
    final choresAsync = ref.watch(choresProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final rankingAsync = ref.watch(familyRankingProvider);

    return currentMember.when(
      data: (currentMember) => membersAsync.when(
        data: (members) {
          return choresAsync.when(
            data: (choresState) => choresState.today.when(
              data: (chores) {
                return achievementsAsync.when(
                  data: (achievements) {
                    return rankingAsync.when(
                      data: (ranking) {
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.familyMembers,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      if (currentMember.isAdmin())
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _openCreate,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            child: GradientWarm(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.add,
                                                  color: AppColors
                                                      .primaryForeground,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...members.map((member) {
                                    final memberRanking = ranking.firstWhere(
                                      (r) => r.id.toString() == member.id,
                                      orElse: () => const RankingMember(
                                        id: 0,
                                        name: '',
                                        points: 0,
                                        roleName: '',
                                        avatar: '👤',
                                      ),
                                    );
                                    final memberPoints = memberRanking.points;
                                    final unlockedAchievements = achievements
                                        .where(
                                          (a) =>
                                              memberPoints >= a.requiredPoints,
                                        )
                                        .length;

                                    final memberChores = chores
                                        .where((c) => c.assignedTo == member.id)
                                        .toList();
                                    final completedChores = memberChores
                                        .where((c) => c.completed)
                                        .length;
                                    return MemberCardComponent(
                                      member: member.copyWith(
                                        points: memberPoints,
                                      ),
                                      tasksCount: memberChores.length,
                                      completedCount: completedChores,
                                      achievementsCount: unlockedAchievements,
                                      onEdit: () => _openEdit(member),
                                      onDelete: () =>
                                          setState(() => _deleteId = member.id),
                                      hasAdminPermission: currentMember
                                          .isAdmin(),
                                    );
                                  }),
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                            if (_dialogOpen)
                              MemberFormDialogComponent(
                                formKey: _memberFormKey,
                                member: member,
                                onCancel: () =>
                                    setState(() => _dialogOpen = false),
                                onSave: _handleSave,
                                onResendPassword: member != null
                                    ? _handleResendPassword
                                    : null,
                                resendPasswordLoading: _resendPasswordLoading,
                              ),
                            if (_deleteId != null)
                              ConfirmActionDialog(
                                title: AppStrings.deleteMember,
                                description: AppStrings.deleteMemberDescription,
                                onCancel: () =>
                                    setState(() => _deleteId = null),
                                onConfirm: _handleDelete,
                              ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text(AppStrings.errorGeneric)),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _buildMembersErrorWidget(context, e, ref),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildMembersErrorWidget(context, e, ref),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildMembersErrorWidget(context, e, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildMembersErrorWidget(context, e, ref),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildMembersErrorWidget(context, e, ref),
    );
  }

  Widget _buildMembersErrorWidget(
    BuildContext context,
    Object? error,
    WidgetRef ref,
  ) {
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
