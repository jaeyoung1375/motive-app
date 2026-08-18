import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step9_page.dart';

/// motive-app `features/onboarding/widget/step12_route.dart`(웨이트 트레이닝 경력)에 대응 —
/// 라우팅 진입점. [Step9Page]가 올려보낸 결과를 `onboardingProvider`에 저장하고 다음 단계로 이동한다.
class Step9Route extends ConsumerWidget {
  const Step9Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step9Page(
      onNext: (experience) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(experienceCd: experience));
        goNextOrReturn(context, '/onboarding/step-10');
      },
    );
  }
}
