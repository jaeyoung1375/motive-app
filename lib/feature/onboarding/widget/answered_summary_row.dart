import 'package:flutter/material.dart';

import 'onboarding_colors.dart';

/// 이전 스텝에서 이미 입력한 값을 회색 요약 줄로 보여주는 위젯.
/// 토스 온보딩 UI처럼 새 질문 아래에 지금까지 답한 항목을 누적해서 보여줄 때 쓴다.
class AnsweredSummaryRow extends StatelessWidget {
  const AnsweredSummaryRow({super.key, required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: OnboardingColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: OnboardingColors.border, width: 1.5)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: OnboardingColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
