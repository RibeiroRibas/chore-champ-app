import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import 'repositories_provider.dart';

class AchievementsNotifier extends AsyncNotifier<List<Achievement>> {
  @override
  Future<List<Achievement>> build() =>
      ref.read(achievementRepositoryProvider).fetchAchievements();
}

final achievementsProvider = AsyncNotifierProvider<AchievementsNotifier, List<Achievement>>(AchievementsNotifier.new);
