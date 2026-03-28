import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/providers/current_member_provider.dart';
import 'package:chore_champ_app/src/providers/repositories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeTodayChoresProvider = FutureProvider<List<Chore>>((ref) async {
  final member = await ref.watch(currentMemberProvider.future);
  return ref.read(choreRepositoryProvider).fetchTodayChores(
        assignedToUserId: int.parse(member.id),
      );
});
