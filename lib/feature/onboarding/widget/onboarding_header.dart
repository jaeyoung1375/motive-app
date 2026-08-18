import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_colors.dart';

/// 뒤로가기 + 진행률 바(+ 선택적 건너뛰기).

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.step, this.onSkip});

  static const totalSteps = 14;

  final int step;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = (step / totalSteps).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BackButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
              ),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: OnboardingColors.point,
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 6,
              width: double.infinity,
              color: OnboardingColors.border,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: OnboardingColors.point),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: OnboardingColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
