import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step6_page.dart';

/// motive-app `features/onboarding/widget/step9_route.dart`(현재 키 입력)에 대응 —
/// 라우팅 진입점. [Step6Page]가 올려보낸 결과를 `onboardingProvider`에 저장하고 다음 단계로 이동한다.
class Step6Route extends ConsumerWidget {
  const Step6Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step6Page(
      onNext: (height) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(height: height.toDouble()));
        goNextOrReturn(context, '/onboarding/step-7');
      },
    );
  }
}
