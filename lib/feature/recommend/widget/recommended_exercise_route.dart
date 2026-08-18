import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/recommended_exercise_models.dart';
import 'recommended_exercise_page.dart';

/// 메인 홈 화면 "추천 운동 미리보기" 버튼의 라우팅 진입점.
/// [state.extra]로 카드가 이미 뽑아둔 목록을 그대로 넘겨받는다.
class RecommendedExerciseRoute extends StatelessWidget {
  const RecommendedExerciseRoute({super.key, required this.exercises});

  final List<RecommendedExerciseResponse> exercises;

  @override
  Widget build(BuildContext context) {
    return RecommendedExercisePage(
      exercises: exercises,
      onBack: () => context.pop(),
      onStart: (exercises) => context.push('/workout-session', extra: exercises),
    );
  }
}
