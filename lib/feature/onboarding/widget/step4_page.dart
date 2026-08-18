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

/// 온보딩 Step 4: 운동 수준 선택.
class Step4Page extends ConsumerStatefulWidget {
  const Step4Page({super.key, required this.onNext});

  final void Function(String level) onNext;

  @override
  ConsumerState<Step4Page> createState() => _Step4PageState();
}

class _Step4PageState extends ConsumerState<Step4Page> {
  String? _level;

  @override
  void initState() {
    super.initState();
    final savedLevel = ref.read(onboardingProvider).levelCd;
    if (savedLevel.isNotEmpty) _level = savedLevel;
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final levelsAsync = ref.watch(codeProvider('HEALTH_LEVEL_CD'));
    final gendersAsync = ref.watch(codeProvider('GENDER_CD'));
    final genderName = gendersAsync.maybeWhen(
      data: (genders) {
        final matches = genders.where((g) => g.dtlCdId == onboarding.gender);
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
                const OnboardingHeader(step: 4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '현재 운동 수준을 알려주세요',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '정확한 난이도의 플랜을 위해 필요해요. 외부에 공개되지 않아요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: OnboardingColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        levelsAsync.when(
                          data: (levels) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < levels.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                SelectOption(
                                  title: levels[i].dtlCdNm,
                                  description: levels[i].dtlCdExpln,
                                  selected: _level == levels[i].dtlCdId,
                                  onTap: () =>
                                      setState(() => _level = levels[i].dtlCdId),
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: Opacity(
                      opacity: _level == null ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed:
                            _level == null ? null : () => widget.onNext(_level!),
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
