import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/code/model/code_models.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'onboarding_colors.dart';

/// motive-app `features/onboarding/widget/step15_page.dart`(온보딩 완료 요약)에 대응 —
/// 온보딩 Step 10: 맞춤 운동 플랜 요약 및 완료.
class Step10Page extends ConsumerWidget {
  const Step10Page({super.key, required this.onFinish});

  final VoidCallback onFinish;

  String _labelOf(List<CodeResponse> codes, String dtlCdId, String fallback) {
    for (final code in codes) {
      if (code.dtlCdId == dtlCdId) return code.dtlCdNm;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingProvider);
    final goals = ref.watch(codeProvider('GOAL_CD')).valueOrNull ?? const [];
    final equipments = ref.watch(codeProvider('EQUIPMENTS_CD')).valueOrNull ?? const [];
    final levels = ref.watch(codeProvider('HEALTH_LEVEL_CD')).valueOrNull ?? const [];

    final stats = [
      ('추천 수준', _labelOf(levels, draft.levelCd, '입문')),
      ('몸무게', '${draft.weight}kg'),
      ('키', '${draft.height}cm'),
      ('주간 운동 횟수', draft.weeklyCount != null ? '주 ${draft.weeklyCount}회' : '주 3회'),
      ('운동 목표', _labelOf(goals, draft.goal, '다이어트')),
      ('운동 장비', _labelOf(equipments, draft.equipmentCd, '맨몸 운동')),
    ];

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 40, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '내게 꼭 맞는 맞춤 운동\n플랜이 준비됐어요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: OnboardingColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '알려주신 정보와 수천만 개의 운동 기록을 비교했어요.',
                      style: TextStyle(fontSize: 14, color: OnboardingColors.textSecondary),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: OnboardingColors.point, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(color: Color(0xFFE4EEFF), shape: BoxShape.circle),
                                  child: const Icon(Icons.track_changes, size: 22, color: OnboardingColors.point),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '나만의 운동 루틴',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OnboardingColors.textPrimary),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.only(top: 20),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: OnboardingColors.border)),
                              ),
                              child: Column(
                                children: [
                                  Row(children: [for (final stat in stats.sublist(0, 3)) Expanded(child: _StatItem(stat))]),
                                  const SizedBox(height: 20),
                                  Row(children: [for (final stat in stats.sublist(3, 6)) Expanded(child: _StatItem(stat))]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: SizedBox(
                        height: 53,
                        child: ElevatedButton(
                          onPressed: onFinish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OnboardingColors.point,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('다음', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.stat);

  final (String label, String value) stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(stat.$1, style: const TextStyle(fontSize: 12, color: OnboardingColors.textPlaceholder)),
        const SizedBox(height: 4),
        Text(
          stat.$2,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: OnboardingColors.textPrimary),
        ),
      ],
    );
  }
}
