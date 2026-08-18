import 'package:flutter/material.dart';

import 'onboarding_colors.dart';

/// 라벨(위) + 밑줄 입력 필드(아래) 형태의 텍스트 입력. [OnboardingFieldTrigger]와
/// 같은 스타일이지만 바텀시트를 여는 대신 직접 타이핑하는 필드에 쓴다.
class OnboardingFieldInput extends StatelessWidget {
  const OnboardingFieldInput({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: OnboardingColors.textPrimary,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.only(bottom: 8),
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OnboardingColors.textPlaceholder,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: OnboardingColors.point, width: 1.5),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: OnboardingColors.point, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: OnboardingColors.point, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
