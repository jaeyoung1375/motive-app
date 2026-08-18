import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'answered_summary_row.dart';
import 'number_field_picker.dart';
import 'onboarding_colors.dart';
import 'onboarding_header.dart';

/// motive-app `features/onboarding/widget/step11_page.dart`(목표 몸무게 입력)에 대응 —
/// 온보딩 Step 8: 목표 몸무게 입력.
class Step8Page extends ConsumerStatefulWidget {
  const Step8Page({super.key, required this.onNext});

  final void Function(num goalWeight) onNext;

  @override
  ConsumerState<Step8Page> createState() => _Step8PageState();
}

class _Step8PageState extends ConsumerState<Step8Page> {
  late num _goalWeight = ref.read(onboardingProvider).goalWeight;

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final gendersAsync = ref.watch(codeProvider('GENDER_CD'));
    final levelsAsync = ref.watch(codeProvider('HEALTH_LEVEL_CD'));
    final equipmentsAsync = ref.watch(codeProvider('EQUIPMENTS_CD'));

    final genderName = gendersAsync.maybeWhen(
      data: (genders) {
        final matches = genders.where((g) => g.dtlCdId == onboarding.gender);
        return matches.isEmpty ? null : matches.first.dtlCdNm;
      },
      orElse: () => null,
    );
    final levelName = levelsAsync.maybeWhen(
      data: (levels) {
        final matches = levels.where((l) => l.dtlCdId == onboarding.levelCd);
        return matches.isEmpty ? null : matches.first.dtlCdNm;
      },
      orElse: () => null,
    );
    final equipmentName = equipmentsAsync.maybeWhen(
      data: (equipments) {
        final matches = equipments.where((e) => e.dtlCdId == onboarding.equipmentCd);
        return matches.isEmpty ? null : matches.first.dtlCdNm;
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingHeader(step: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '목표 몸무게가 어떻게 되시나요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EEFF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: OnboardingColors.point, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 14, color: OnboardingColors.point),
                                  SizedBox(width: 6),
                                  Text(
                                    '건강한 목표 몸무게를 추천 드렸어요',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: OnboardingColors.point,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${formatOnboardingNumber(onboarding.height)}cm·${formatOnboardingNumber(onboarding.weight)}kg 기준의 건강한 목표 체중이에요.',
                                style: const TextStyle(fontSize: 12, color: OnboardingColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'WHO · 대한비만학회 건강 체중 BMI 기준',
                                style: TextStyle(fontSize: 11, color: OnboardingColors.textPlaceholder),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        NumberFieldPicker(
                          label: '목표 몸무게',
                          sheetTitle: '목표 몸무게를 알려주세요',
                          value: _goalWeight,
                          unit: 'kg',
                          onChanged: (v) => setState(() => _goalWeight = v),
                        ),
                        const SizedBox(height: 24),
                        AnsweredSummaryRow(
                          label: '이름',
                          value: onboarding.nickname,
                          onTap: () => context.go(editStepRoute(context, '/onboarding/step-1')),
                        ),
                        if (genderName != null)
                          AnsweredSummaryRow(
                            label: '성별',
                            value: genderName,
                            onTap: () => context.go(editStepRoute(context, '/onboarding/step-2')),
                          ),
                        if (onboarding.birth.length == 8)
                          AnsweredSummaryRow(
                            label: '생년월일',
                            value:
                                '${onboarding.birth.substring(0, 4)}.${onboarding.birth.substring(4, 6)}.${onboarding.birth.substring(6, 8)}',
                            onTap: () => context.go(editStepRoute(context, '/onboarding/step-3')),
                          ),
                        if (levelName != null)
                          AnsweredSummaryRow(
                            label: '운동 수준',
                            value: levelName,
                            onTap: () => context.go(editStepRoute(context, '/onboarding/step-4')),
                          ),
                        if (equipmentName != null)
                          AnsweredSummaryRow(
                            label: '사용 기구',
                            value: equipmentName,
                            onTap: () => context.go(editStepRoute(context, '/onboarding/step-5')),
                          ),
                        AnsweredSummaryRow(
                          label: '키',
                          value: '${formatOnboardingNumber(onboarding.height)}cm',
                          onTap: () => context.go(editStepRoute(context, '/onboarding/step-6')),
                        ),
                        AnsweredSummaryRow(
                          label: '몸무게',
                          value: '${formatOnboardingNumber(onboarding.weight)}kg',
                          onTap: () => context.go(editStepRoute(context, '/onboarding/step-7')),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: ElevatedButton(
                      onPressed: () => widget.onNext(_goalWeight),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OnboardingColors.point,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
