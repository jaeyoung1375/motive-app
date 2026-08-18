import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';

import 'answered_summary_row.dart';
import 'birth_date_picker.dart';
import 'onboarding_colors.dart';
import 'onboarding_header.dart';

/// 온보딩 Step 3: 생년월일 입력.
class Step3Page extends ConsumerStatefulWidget {
  const Step3Page({super.key, required this.onNext});

  final void Function(String birthDate) onNext;

  @override
  ConsumerState<Step3Page> createState() => _Step3PageState();
}

class _Step3PageState extends ConsumerState<Step3Page> {
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(onboardingProvider).birth;
    if (saved.length == 8) {
      _birthDate = DateTime(
        int.parse(saved.substring(0, 4)),
        int.parse(saved.substring(4, 6)),
        int.parse(saved.substring(6, 8)),
      );
    }
  }

  String _toYyyyMmDd(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
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
                const OnboardingHeader(step: 3),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '생년월일이 어떻게 되시나요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '나이는 신체 수준을 파악하여 운동 플랜을 제공하는데 필요해요. 절대 외부에 공개되지 않아요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: OnboardingColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        BirthDatePicker(
                          value: _birthDate,
                          onChanged: (date) =>
                              setState(() => _birthDate = date),
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: Opacity(
                      opacity: _birthDate == null ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed: _birthDate == null
                            ? null
                            : () =>
                                  widget.onNext(_toYyyyMmDd(_birthDate!)),
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
