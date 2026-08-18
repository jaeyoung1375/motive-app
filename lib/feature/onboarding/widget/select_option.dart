import 'package:flutter/material.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_colors.dart';

/// motive-ui `app/onboarding/components/SelectOption.tsx`에 대응 — 성별 / 운동 수준 /
/// 기구 / 트레이닝 경력 등 단일 선택 항목에서 공용으로 쓰는 선택지 버튼.
class SelectOption extends StatelessWidget {
  const SelectOption({
    super.key,
    required this.title,
    this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  static const _selectedBackground = Color(0xFFE4EEFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _selectedBackground : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? OnboardingColors.point
                  : OnboardingColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OnboardingColors.textPrimary,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: OnboardingColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
