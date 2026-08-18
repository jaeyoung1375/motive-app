import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step4_page.dart';

/// motive-ui `app/onboarding/step-6/page.tsx`(운동 수준)에 대응 — 라우팅 진입점.
/// [Step4Page]가 올려보낸 결과를 `onboardingProvider`에 저장하고 다음 단계로 이동한다.
class Step4Route extends ConsumerWidget {
  const Step4Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step4Page(
      onNext: (level) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(levelCd: level));
        goNextOrReturn(context, '/onboarding/step-5');
      },
    );
  }
}
