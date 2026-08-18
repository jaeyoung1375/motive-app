import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'step10_page.dart';

/// motive-app `features/onboarding/widget/step15_route.dart`(온보딩 완료)에 대응 —
/// 라우팅 진입점. 완료 시 지금까지 모은 `onboardingProvider` 상태를 `insertProfile`로
/// 제출하고, 성공하면 상태를 초기화한 뒤 `/`(홈)로 이동한다.
class Step10Route extends ConsumerWidget {
  const Step10Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step10Page(
      onFinish: () async {
        await ref.read(onboardingSubmitControllerProvider.notifier).submit();
        if (ref.read(onboardingSubmitControllerProvider).hasError) return;

        ref.read(onboardingProvider.notifier).reset();
        if (context.mounted) context.go('/');
      },
    );
  }
}
