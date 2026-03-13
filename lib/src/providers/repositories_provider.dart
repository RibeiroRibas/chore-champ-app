import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/repositories/achievement_repository.dart';
import 'package:chore_champ_app/src/repositories/auth_repository.dart';
import 'package:chore_champ_app/src/repositories/chore_repository.dart';
import 'package:chore_champ_app/src/repositories/family_repository.dart';
import 'package:chore_champ_app/src/repositories/reward_repository.dart';
import 'package:chore_champ_app/src/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) => AchievementRepository());

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository(ref.watch(apiClientProvider)));

final choreRepositoryProvider = Provider<ChoreRepository>(
  (ref) => ChoreRepository(ref.watch(apiClientProvider)),
);

final memberRepositoryProvider = Provider<FamilyRepository>((ref) => FamilyRepository(ref.watch(apiClientProvider)));

final rewardRepositoryProvider = Provider<RewardRepository>((ref) => RewardRepository());
