import '../../../core/network/api_client.dart';
import '../model/recommended_exercise_models.dart';

class RecommendedExerciseApi {
  RecommendedExerciseApi(this._client);

  final ApiClient _client;

  Future<List<RecommendedExerciseResponse>> fetchRandom({int count = 5}) => _client.get(
        '/api/v1/recommended-exercises',
        queryParameters: {'count': count},
        fromJsonT: (json) =>
            (json as List).map((e) => RecommendedExerciseResponse.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
