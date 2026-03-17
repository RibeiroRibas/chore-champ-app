import 'package:dio/dio.dart';

import 'package:chore_champ_app/src/infra/api_client.dart';
import 'package:chore_champ_app/src/models/day_of_week.dart';

class DayOfWeekRepository {
  DayOfWeekRepository(this._client);

  final ApiClient _client;

  static const String _path = '/days-of-week';

  Future<List<DayOfWeek>> fetchDaysOfWeek() async {
    try {
      final data = await _client.get<List<dynamic>>(_path);
      return (data)
          .map((e) => DayOfWeek.fromApiJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) _client.throwFromResponse(e.response!);
      rethrow;
    }
  }
}
