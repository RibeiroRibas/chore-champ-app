import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/family_member.dart';
import '../../widgets/gradient_warm.dart';

class DashboardGreetingComponent extends StatelessWidget {
  const DashboardGreetingComponent({
    super.key,
    required this.currentUser,
    required this.completedToday,
    required this.totalChores,
  });

  final FamilyMember currentUser;
  final int completedToday;
  final int totalChores;

  @override
  Widget build(BuildContext context) {
    return GradientWarm(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeBackGreeting,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryForeground.withValues(alpha: 0.9),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentUser.avatar} ${currentUser.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryForeground),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.primaryForeground, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$completedToday/$totalChores ${AppStrings.choresCompleted}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryForeground,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
