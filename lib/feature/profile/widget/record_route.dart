import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../workout_record/model/workout_record_models.dart';
import 'record_page.dart';

/// `RecordRoute`의 [GoRouterState.extra]로 넘기는 값 — 신규 등록 시 초기 날짜,
/// 또는 수정 시 대상 기록을 함께 실어나른다.
class RecordRouteArgs {
  const RecordRouteArgs({this.initialDate, this.editingRecord});

  final DateTime? initialDate;
  final WorkoutRecordResponse? editingRecord;
}

/// motive-app `features/profile/widget/record_route.dart`에 대응 — 라우팅 진입점.
class RecordRoute extends StatelessWidget {
  const RecordRoute({super.key, this.args});

  final RecordRouteArgs? args;

  @override
  Widget build(BuildContext context) {
    final editingRecord = args?.editingRecord;
    return RecordPage(
      initialDate: args?.initialDate,
      editingRecord: editingRecord,
      onBack: () => context.pop(),
      onAddExercise: () => context.push('/exercises?select=1'),
      // 수정 완료 시 상세 화면으로 되돌아가고, 신규 등록은 기존대로 프로필로 이동한다.
      onSubmitted: () => editingRecord != null ? context.pop() : context.go('/profile'),
      onLoadPrevious: () => context.push('/profile/record/previous'),
    );
  }
}
