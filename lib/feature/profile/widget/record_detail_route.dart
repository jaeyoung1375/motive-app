import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'record_detail_page.dart';
import 'record_route.dart';

/// motive-app `features/profile/widget/record_detail_route.dart`에 대응 — 라우팅 진입점.
class RecordDetailRoute extends StatelessWidget {
  const RecordDetailRoute({super.key, required this.workoutRecordId});

  final int workoutRecordId;

  @override
  Widget build(BuildContext context) {
    return RecordDetailPage(
      workoutRecordId: workoutRecordId,
      onBack: () => context.pop(),
      onEdit: (record) =>
          context.push('/profile/record', extra: RecordRouteArgs(editingRecord: record)),
      onDeleted: () => context.go('/profile'),
    );
  }
}
