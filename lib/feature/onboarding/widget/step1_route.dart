import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step1_page.dart';

class Step1Route extends ConsumerWidget {
  const Step1Route({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Step1Page(
      onNext: (name, imageBytes, imageName) {
        ref
            .read(onboardingProvider.notifier)
            .update(
              (state) => state.copyWith(
                nickname: name,
                profileImageBytes: imageBytes,
                profileImageName: imageName,
              ),
            );
        goNextOrReturn(context, '/onboarding/step-2');
      },
    );
  }
}
