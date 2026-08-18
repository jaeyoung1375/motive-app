import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_colors.dart';

/// motive-app `features/onboarding/widget/number_field.dart`에 대응 — 키/몸무게/목표
/// 몸무게 등에서 재사용하는 큰 숫자 입력 필드.
class NumberField extends StatefulWidget {
  const NumberField({super.key, required this.value, required this.onChanged, required this.unit});

  final num value;
  final ValueChanged<num> onChanged;
  final String unit;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _controller = TextEditingController(text: _format(widget.value));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(num value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: OnboardingColors.textPrimary),
            decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
            onChanged: (text) {
              final parsed = num.tryParse(text);
              if (parsed != null) widget.onChanged(parsed);
            },
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.unit,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: OnboardingColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
