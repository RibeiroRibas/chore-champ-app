import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


final _navItems = [
  (path: '/', icon: Icons.home_rounded, label: AppStrings.home),
  (path: '/chores', icon: Icons.list_alt_rounded, label: AppStrings.chores),
  (
    path: '/achievements',
    icon: Icons.emoji_events_rounded,
    label: AppStrings.achieve,
  ),
  (
    path: '/rewards',
    icon: Icons.card_giftcard_rounded,
    label: AppStrings.rewards,
  ),
  (
    path: '/family',
    icon: Icons.people_rounded,
    label: AppStrings.familyMembers,
  ),
];

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.map((item) {
              final active = location == item.path;
              return InkWell(
                onTap: () => context.go(item.path),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: active
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.path == '/family' ? AppStrings.family : item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? AppColors.primary
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
