import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step3_page.dart';

/// motive-ui `app/onboarding/step-3/page.tsx`에 대응 — 라우팅 진입점.
/// [Step3Page]가 올려보낸 결과를 `onboardingProvider`에 저장하고 다음 단계로 이동한다.
class Step3Route extends ConsumerWidget {
  const Step3Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step3Page(
      onNext: (birthDate) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(birth: birthDate));
        goNextOrReturn(context, '/onboarding/step-4');
      },
    );
  }
}
