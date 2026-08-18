import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/recommended_exercise_api.dart';
import '../model/recommended_exercise_models.dart';

final recommendedExerciseApiProvider = Provider<RecommendedExerciseApi>(
  (ref) => RecommendedExerciseApi(ref.watch(apiClientProvider)),
);

/// 메인 홈 화면 "오늘의 추천 운동" 카드 — 새로고침은 `ref.invalidate(recommendedExerciseListProvider)`로
/// 다시 호출해 서버에서 무작위로 다시 뽑게 한다.
final recommendedExerciseListProvider = FutureProvider<List<RecommendedExerciseResponse>>(
  (ref) => ref.watch(recommendedExerciseApiProvider).fetchRandom(),
);
