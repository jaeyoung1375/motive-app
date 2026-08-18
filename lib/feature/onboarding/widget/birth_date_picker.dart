import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'onboarding_colors.dart';
import 'onboarding_field_trigger.dart';

/// motive-ui `components/BirthDatePicker.tsx`에 대응 — 연/월/일 휠 스크롤로 생년월일을
/// 고르는 바텀시트. 원본은 커스텀 스크롤 휠이지만, 동일한 상호작용(휠 스크롤 + 확인 버튼이
/// 있는 바텀시트)을 제공하는 Flutter 표준 위젯인 [CupertinoDatePicker]로 대체했다.
class BirthDatePicker extends StatelessWidget {
  const BirthDatePicker({super.key, required this.value, required this.onChanged, this.placeholder = '생년월일 선택'});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String placeholder;

  Future<void> _open(BuildContext context) async {
    final now = DateTime.now();
    var picked = value ?? DateTime(now.year - 20, 1, 1);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
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
                  '생년월일을 알려주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OnboardingColors.textPrimary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    dateOrder: DatePickerDateOrder.ymd,
                    initialDateTime: picked,
                    minimumYear: now.year - 100,
                    maximumYear: now.year,
                    onDateTimeChanged: (date) => picked = date,
                  ),
                ),
                const SizedBox(height: 16),
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
            ),
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  String _format(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return OnboardingFieldTrigger(
      label: '생년월일',
      value: value != null ? _format(value!) : null,
      placeholder: placeholder,
      onTap: () => _open(context),
    );
  }
}
