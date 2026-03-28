import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/achievements_provider.dart';
import '../providers/chores_provider.dart';
import '../providers/current_member_provider.dart';
import '../providers/home_today_chores_provider.dart';
import '../providers/family_ranking_provider.dart';
import '../providers/members_provider.dart';
import '../providers/rewards_provider.dart';

Future<void> pullRefreshHome(WidgetRef ref) {
  return Future.wait([
    ref.refresh(currentMemberProvider.future),
    ref.refresh(homeTodayChoresProvider.future),
    ref.read(choresProvider.notifier).refreshTodayForPull(),
    ref.refresh(membersProvider.future),
    ref.refresh(achievementsProvider.future),
    ref.refresh(familyRankingProvider.future),
  ]);
}

Future<void> pullRefreshChoresTab(WidgetRef ref) {
  return Future.wait([
    ref.refresh(currentMemberProvider.future),
    ref.refresh(homeTodayChoresProvider.future),
    ref.read(choresProvider.notifier).refreshChoresTabForPull(),
    ref.refresh(membersProvider.future),
  ]);
}

Future<void> pullRefreshAchievements(WidgetRef ref) {
  return Future.wait([
    ref.refresh(currentMemberProvider.future),
    ref.refresh(achievementsProvider.future),
  ]);
}

Future<void> pullRefreshRewards(WidgetRef ref) {
  return Future.wait([
    ref.refresh(currentMemberProvider.future),
    ref.refresh(rewardsProvider.future),
    ref.refresh(achievementsProvider.future),
  ]);
}

Future<void> pullRefreshFamily(WidgetRef ref) {
  return Future.wait([
    ref.refresh(currentMemberProvider.future),
    ref.refresh(membersProvider.future),
    ref.refresh(homeTodayChoresProvider.future),
    ref.read(choresProvider.notifier).refreshTodayForPull(),
    ref.refresh(achievementsProvider.future),
    ref.refresh(familyRankingProvider.future),
  ]);
}
