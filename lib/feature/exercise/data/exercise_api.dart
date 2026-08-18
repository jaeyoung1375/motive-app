import '../../../core/network/api_client.dart';
import '../model/exercise_models.dart';

/// motive-ui `features/exercise/exercise.api.ts`에 대응.
class ExerciseApi {
  ExerciseApi(this._client);

  final ApiClient _client;

  Future<List<ExerciseResponse>> fetchList({String? name, String? bodyPartCd}) => _client.get(
        '/api/v1/exercises',
        queryParameters: {'name': ?name, 'bodyPartCd': ?bodyPartCd},
        fromJsonT: (json) =>
            (json as List).map((e) => ExerciseResponse.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
