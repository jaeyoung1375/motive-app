import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'previous_record_page.dart';

/// motive-app `features/profile/widget/previous_record_route.dart`에 대응 —
/// RecordPage의 "이전 기록 불러오기" 진입점.
class PreviousRecordRoute extends StatelessWidget {
  const PreviousRecordRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return PreviousRecordPage(onClose: () => context.pop());
  }
}
