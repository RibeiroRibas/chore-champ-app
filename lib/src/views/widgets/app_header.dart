import 'package:chore_champ_app/src/models/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/family_member.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/members_provider.dart';
import '../../providers/session_provider.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final membersAsync = ref.watch(membersProvider);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.appName, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    currentUser.role == Role.admin
                        ? AppStrings.roleAdmin
                        : AppStrings.roleCollaborator,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.points.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${currentUser.points}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pointsForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            membersAsync.when(
              data: (members) => _buildUserDropdown(context, ref, currentUser, members),
              loading: () => const SizedBox(width: 80, height: 36),
              error: (_, __) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.mutedForeground, size: 22),
              tooltip: AppStrings.signOut,
              onPressed: () {
                ref.read(sessionProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDropdown(BuildContext context, WidgetRef ref, FamilyMember currentUser, List<FamilyMember> members) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentUser.id,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.foreground),
          items: members
              .map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text('${m.avatar} ${m.name}', style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (id) {
            if (id != null) ref.read(currentUserIdProvider.notifier).persist(id);
          },
        ),
      ),
    );
  }
}
