import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/util/date_util.dart';
import '../../recommend/model/recommended_exercise_models.dart';
import '../../workout_record/provider/workout_record_provider.dart';
import 'workout_session_page.dart';

/// "추천 운동 미리보기" 화면의 "시작하기" 버튼 진입점.
/// [state.extra]로 그 화면에서 확정한 운동 목록을 그대로 넘겨받는다.
/// 모든 세트를 마치면 운동기록을 등록하고, 성공하면 홈으로 이동한다.
class WorkoutSessionRoute extends ConsumerWidget {
  const WorkoutSessionRoute({super.key, required this.exercises});

  final List<RecommendedExerciseResponse> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkoutSessionPage(
      exercises: exercises,
      onBack: () => context.pop(),
      onFinish: (request) async {
        await ref.read(workoutRecordControllerProvider.notifier).create(
              request,
              affectedYearMonth: DateUtil.formatYearMonth(DateTime.now()),
            );
        if (!context.mounted) return;

        if (ref.read(workoutRecordControllerProvider).hasError) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('운동 기록 등록에 실패했습니다.')));
          return;
        }
        context.go('/');
      },
    );
  }
}
