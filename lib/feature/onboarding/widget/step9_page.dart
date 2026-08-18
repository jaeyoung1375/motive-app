import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/code/model/code_models.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'answered_summary_row.dart';
import 'number_field_picker.dart';
import 'onboarding_colors.dart';
import 'onboarding_field_trigger.dart';
import 'onboarding_header.dart';

/// 온보딩 Step 9: 헬스 경력 선택.
class Step9Page extends ConsumerStatefulWidget {
  const Step9Page({super.key, required this.onNext});

  final void Function(String experience) onNext;

  @override
  ConsumerState<Step9Page> createState() => _Step9PageState();
}

class _Step9PageState extends ConsumerState<Step9Page> {
  String? _experience;

  @override
  void initState() {
    super.initState();
    final savedExperience = ref.read(onboardingProvider).experienceCd;
    if (savedExperience.isNotEmpty) _experience = savedExperience;
  }

  Future<void> _openExperienceSheet(List<CodeResponse> experiences) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    decoration: BoxDecoration(
                      color: OnboardingColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Text(
                  '헬스 경력을 알려주세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OnboardingColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final experience in experiences)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      experience.dtlCdNm,
                      style: const TextStyle(
                        fontSize: 15,
                        color: OnboardingColors.textPrimary,
                      ),
                    ),
                    trailing: _experience == experience.dtlCdId
                        ? const Icon(Icons.check, color: OnboardingColors.point)
                        : null,
                    onTap: () => Navigator.of(context).pop(experience.dtlCdId),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) setState(() => _experience = selected);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final experiencesAsync = ref.watch(codeProvider('EXPERIENCE_CD'));
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
        final matches = equipments.where(
          (e) => e.dtlCdId == onboarding.equipmentCd,
        );
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
                const OnboardingHeader(step: 9),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '규칙적으로 웨이트 트레이닝을 한 지 얼마나 됐나요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        experiencesAsync.when(
                          data: (experiences) => OnboardingFieldTrigger(
                            label: '헬스 경력',
                            value: _experience == null
                                ? null
                                : experiences
                                      .firstWhere(
                                        (e) => e.dtlCdId == _experience,
                                      )
                                      .dtlCdNm,
                            placeholder: '경력을 선택해주세요',
                            onTap: () => _openExperienceSheet(experiences),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),
                        AnsweredSummaryRow(
                          label: '이름',
                          value: onboarding.nickname,
                          onTap: () => context.go(
                            editStepRoute(context, '/onboarding/step-1'),
                          ),
                        ),
                        if (genderName != null)
                          AnsweredSummaryRow(
                            label: '성별',
                            value: genderName,
                            onTap: () => context.go(
                              editStepRoute(context, '/onboarding/step-2'),
                            ),
                          ),
                        if (onboarding.birth.length == 8)
                          AnsweredSummaryRow(
                            label: '생년월일',
                            value:
                                '${onboarding.birth.substring(0, 4)}.${onboarding.birth.substring(4, 6)}.${onboarding.birth.substring(6, 8)}',
                            onTap: () => context.go(
                              editStepRoute(context, '/onboarding/step-3'),
                            ),
                          ),
                        if (levelName != null)
                          AnsweredSummaryRow(
                            label: '운동 수준',
                            value: levelName,
                            onTap: () => context.go(
                              editStepRoute(context, '/onboarding/step-4'),
                            ),
                          ),
                        if (equipmentName != null)
                          AnsweredSummaryRow(
                            label: '사용 기구',
                            value: equipmentName,
                            onTap: () => context.go(
                              editStepRoute(context, '/onboarding/step-5'),
                            ),
                          ),
                        AnsweredSummaryRow(
                          label: '키',
                          value:
                              '${formatOnboardingNumber(onboarding.height)}cm',
                          onTap: () => context.go(
                            editStepRoute(context, '/onboarding/step-6'),
                          ),
                        ),
                        AnsweredSummaryRow(
                          label: '몸무게',
                          value:
                              '${formatOnboardingNumber(onboarding.weight)}kg',
                          onTap: () => context.go(
                            editStepRoute(context, '/onboarding/step-7'),
                          ),
                        ),
                        AnsweredSummaryRow(
                          label: '목표 몸무게',
                          value:
                              '${formatOnboardingNumber(onboarding.goalWeight)}kg',
                          onTap: () => context.go(
                            editStepRoute(context, '/onboarding/step-8'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: Opacity(
                      opacity: _experience == null ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed: _experience == null
                            ? null
                            : () => widget.onNext(_experience!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingColors.point,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: OnboardingColors.point,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
