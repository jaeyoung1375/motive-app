import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_nav.dart';
import 'package:motive_app_toy/feature/code/model/code_models.dart';
import 'package:motive_app_toy/feature/code/provider/code_provider.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';
import 'package:motive_app_toy/feature/onboarding/widget/answered_summary_row.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_colors.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_field_trigger.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_header.dart';

class Step2Page extends ConsumerStatefulWidget {
  const Step2Page({super.key, required this.onNext});

  final void Function(String gender) onNext;

  @override
  ConsumerState<Step2Page> createState() => _Step2PageState();
}

class _Step2PageState extends ConsumerState<Step2Page> {
  String? _gender;

  @override
  void initState() {
    super.initState();
    final savedGender = ref.read(onboardingProvider).gender;
    if (savedGender.isNotEmpty) _gender = savedGender;
  }

  Future<void> _openGenderSheet(List<CodeResponse> genders) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    decoration: BoxDecoration(color: OnboardingColors.border, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const Text(
                  '성별을 알려주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OnboardingColors.textPrimary),
                ),
                const SizedBox(height: 12),
                for (final gender in genders)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      gender.dtlCdNm,
                      style: const TextStyle(fontSize: 15, color: OnboardingColors.textPrimary),
                    ),
                    trailing: _gender == gender.dtlCdId
                        ? const Icon(Icons.check, color: OnboardingColors.point)
                        : null,
                    onTap: () => Navigator.of(context).pop(gender.dtlCdId),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) setState(() => _gender = selected);
  }

  @override
  Widget build(BuildContext context) {
    final nickname = ref.watch(onboardingProvider).nickname;
    final gendersAsync = ref.watch(codeProvider('GENDER_CD'));

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingHeader(step: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '성별이 어떻게 되시나요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '적절한 운동 추천에 필요해요! 외부에 공개되지 않아요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: OnboardingColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        gendersAsync.when(
                          data: (genders) => OnboardingFieldTrigger(
                            label: '성별',
                            value: _gender == null
                                ? null
                                : genders
                                    .firstWhere((g) => g.dtlCdId == _gender)
                                    .dtlCdNm,
                            placeholder: '성별을 선택해주세요',
                            onTap: () => _openGenderSheet(genders),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),
                        AnsweredSummaryRow(
                          label: '이름',
                          value: nickname,
                          onTap: () => context.go(editStepRoute(context, '/onboarding/step-1')),
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
                      opacity: _gender == null ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed: _gender == null
                            ? null
                            : () => widget.onNext(_gender!),
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
