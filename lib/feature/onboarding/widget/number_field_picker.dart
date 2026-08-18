import 'package:flutter/material.dart';

import 'number_field.dart';
import 'onboarding_colors.dart';
import 'onboarding_field_trigger.dart';

/// 키/몸무게 등 `num` 값을 정수면 소수점 없이, 아니면 그대로 문자열로 만든다.
String formatOnboardingNumber(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// 키/몸무게처럼 숫자를 입력받는 필드를 바텀시트로 감싼 트리거.
/// [BirthDatePicker]와 같은 구조(트리거 → 바텀시트 → 확인 버튼)를 숫자 입력에 맞게 재사용한다.
class NumberFieldPicker extends StatelessWidget {
  const NumberFieldPicker({
    super.key,
    required this.label,
    required this.sheetTitle,
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final String sheetTitle;
  final num value;
  final String unit;
  final ValueChanged<num> onChanged;

  Future<void> _open(BuildContext context) async {
    var picked = value;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(26, 8, 26, 24 + keyboardInset),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
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
                    Text(
                      sheetTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: OnboardingColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    NumberField(
                      value: picked,
                      unit: unit,
                      onChanged: (v) => setSheetState(() => picked = v),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () {
                          onChanged(picked);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingColors.point,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('선택하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingFieldTrigger(
      label: label,
      value: '${formatOnboardingNumber(value)}$unit',
      onTap: () => _open(context),
    );
  }
}
