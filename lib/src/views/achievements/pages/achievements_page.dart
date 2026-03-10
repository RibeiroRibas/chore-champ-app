import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_strings.dart';
import '../../../models/achievement.dart';
import '../../../providers/achievements_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../components/achievement_card_component.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return achievementsAsync.when(
      data: (achievements) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.achievements, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, i) {
                  final a = achievements[i];
                  final unlocked = a.unlockedBy.contains(currentUser.id);
                  final progress = (currentUser.points / a.requiredPoints * 100).clamp(0.0, 100.0);
                  return AchievementCardComponent(
                    achievement: a,
                    unlocked: unlocked,
                    progress: progress,
                    currentUserPoints: currentUser.points,
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppStrings.errorGeneric)),
    );
  }
}
