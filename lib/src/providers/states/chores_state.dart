import 'package:chore_champ_app/src/models/chore.dart';
import 'package:chore_champ_app/src/models/paginated_chores_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChoresState {
  const ChoresState({required this.today, required this.allPaginated});

  final AsyncValue<List<Chore>> today;
  final AsyncValue<PaginatedChoresResponse?> allPaginated;
}
