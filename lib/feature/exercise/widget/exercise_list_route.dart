import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../workout_record/provider/record_draft_provider.dart';
import 'exercise_list_page.dart';

/// motive-app `features/exercise/widget/exercise_list_route.dart`에 대응 — 라우팅 진입점.
/// `?select=1`이면 운동기록 작성 중 운동 추가 흐름으로, 선택한 운동을
/// `recordDraftProvider`에 담고 이전 화면으로 되돌아간다.
class ExerciseListRoute extends ConsumerWidget {
  const ExerciseListRoute({super.key, required this.isSelectMode});

  final bool isSelectMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExerciseListPage(
      onBack: () => context.pop(),
      onSelect: isSelectMode
          ? (exercise) {
              ref.read(recordDraftProvider.notifier).addExercise(exercise);
              context.pop();
            }
          : null,
    );
  }
}
