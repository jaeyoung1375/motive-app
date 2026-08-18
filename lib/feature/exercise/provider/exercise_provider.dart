import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/exercise_api.dart';
import '../model/exercise_models.dart';

final exerciseApiProvider = Provider<ExerciseApi>((ref) => ExerciseApi(ref.watch(apiClientProvider)));

/// motive-ui `features/exercise/exercise.query.ts`의 목록 조회 훅에 대응(공개 API).
final exerciseListProvider = FutureProvider<List<ExerciseResponse>>(
  (ref) => ref.watch(exerciseApiProvider).fetchList(),
);
