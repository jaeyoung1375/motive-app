import 'package:flutter/material.dart';

import 'onboarding_colors.dart';

/// 라벨(위) + 값(아래, 밑줄) 형태의 탭 가능한 필드. 바텀시트를 여는 트리거로 쓴다
/// (토스 온보딩의 "생년월일"/"성별" 입력 필드 스타일).
class OnboardingFieldTrigger extends StatelessWidget {
  const OnboardingFieldTrigger({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder,
  });

  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: OnboardingColors.point,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: OnboardingColors.point, width: 1.5)),
            ),
            child: Text(
              hasValue ? value! : (placeholder ?? ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasValue ? OnboardingColors.textPrimary : OnboardingColors.textPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
