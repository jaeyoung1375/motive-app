import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'settings_page.dart';

/// motive-app `features/settings/widget/settings_route.dart`에 대응 —
/// 하단 탭바 "전체" 진입점.
class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPage(onBack: () => context.pop());
  }
}
