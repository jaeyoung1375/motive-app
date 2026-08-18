import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step5_page.dart';

/// motive-app `features/onboarding/widget/step7_route.dart`(사용 기구 선택)에 대응 —
/// 라우팅 진입점. [Step5Page]가 올려보낸 결과를 `onboardingProvider`에 저장하고 다음 단계로 이동한다.
class Step5Route extends ConsumerWidget {
  const Step5Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step5Page(
      onNext: (equipment) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(equipmentCd: equipment));
        goNextOrReturn(context, '/onboarding/step-6');
      },
    );
  }
}
