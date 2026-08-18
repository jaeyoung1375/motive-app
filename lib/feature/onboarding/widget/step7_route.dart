import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step7_page.dart';

/// motive-app `features/onboarding/widget/step10_route.dart`(현재 몸무게 입력)에 대응 —
/// 라우팅 진입점. motive-app 원본과 동일하게 목표 몸무게 기본값(`weight - 2`)도 이 시점에 함께 채운다.
class Step7Route extends ConsumerWidget {
  const Step7Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step7Page(
      onNext: (weight) {
        ref.read(onboardingProvider.notifier).update(
              (state) => state.copyWith(
                weight: weight.toDouble(),
                goalWeight: weight.toDouble() - 2,
              ),
            );
        goNextOrReturn(context, '/onboarding/step-8');
      },
    );
  }
}
