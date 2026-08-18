import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'landing_page.dart';

/// motive-ui `app/page.tsx`가 `onboardingCompleted === false`일 때 렌더링하는
/// `<LandingPage onGetStarted={...} />` 분기에 대응.
class LandingRoute extends StatelessWidget {
  const LandingRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingPage(onGetStarted: () => context.go('/onboarding/step-1'));
  }
}
