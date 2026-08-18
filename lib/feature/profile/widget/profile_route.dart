import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'profile_page.dart';
import 'record_route.dart';

/// motive-app `features/profile/widget/profile_route.dart`에 대응 — 라우팅 진입점.
class ProfileRoute extends StatelessWidget {
  const ProfileRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      onAddRecord: (recordDt) =>
          context.push('/profile/record', extra: RecordRouteArgs(initialDate: recordDt)),
      onOpenRecordDetail: (workoutRecordId) => context.push('/profile/record/$workoutRecordId'),
      onOpenSettings: () => context.push('/settings'),
    );
  }
}
