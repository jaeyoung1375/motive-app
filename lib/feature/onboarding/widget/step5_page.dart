import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'answered_summary_row.dart';
import 'onboarding_colors.dart';
import 'onboarding_header.dart';
import 'select_option.dart';

/// motive-app `features/onboarding/widget/step7_page.dart`(사용 기구 선택)에 대응 —
/// 온보딩 Step 5: 사용 기구 선택.
class Step5Page extends ConsumerStatefulWidget {
  const Step5Page({super.key, required this.onNext});

  final void Function(String equipment) onNext;

  @override
  ConsumerState<Step5Page> createState() => _Step5PageState();
}

class _Step5PageState extends ConsumerState<Step5Page> {
  String? _equipment;

  @override
  void initState() {
    super.initState();
    final savedEquipment = ref.read(onboardingProvider).equipmentCd;
    if (savedEquipment.isNotEmpty) _equipment = savedEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final equipmentsAsync = ref.watch(codeProvider('EQUIPMENTS_CD'));
    final gendersAsync = ref.watch(codeProvider('GENDER_CD'));
    final levelsAsync = ref.watch(codeProvider('HEALTH_LEVEL_CD'));

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

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingHeader(step: 5),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '운동할 때 어떤 기구를 가장 자주 쓰시나요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '사용하고 있는 기구에 딱 맞게 추천해 드릴게요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: OnboardingColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        equipmentsAsync.when(
                          data: (equipments) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < equipments.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                SelectOption(
                                  title: equipments[i].dtlCdNm,
                                  description: equipments[i].dtlCdExpln,
                                  selected: _equipment == equipments[i].dtlCdId,
                                  onTap: () => setState(
                                    () => _equipment = equipments[i].dtlCdId,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => const SizedBox.shrink(),
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: Opacity(
                      opacity: _equipment == null ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed: _equipment == null
                            ? null
                            : () => widget.onNext(_equipment!),
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
