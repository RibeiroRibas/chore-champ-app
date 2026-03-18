import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chore_champ_app/src/models/ranking_member.dart';

import 'repositories_provider.dart';

final familyRankingProvider =
    FutureProvider<List<RankingMember>>((ref) async {
  return ref.read(memberRepositoryProvider).fetchRanking();
});
