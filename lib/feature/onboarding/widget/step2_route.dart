import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step2_page.dart';

class Step2Route extends ConsumerWidget {
  const Step2Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step2Page(
      onNext: (gender) {
        ref
            .read(onboardingProvider.notifier)
            .update((state) => state.copyWith(gender: gender));
        goNextOrReturn(context, '/onboarding/step-3');
      },
    );
  }
}
