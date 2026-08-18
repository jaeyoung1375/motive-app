import 'dart:math';

import 'package:flutter/material.dart';

/// motive-ui의 `border-dashed`(Tailwind)에 대응하는 원형 점선 테두리.
/// Flutter에는 기본 제공되는 점선 테두리가 없어 CustomPainter로 직접 그린다.
class DashedCircleBorder extends StatelessWidget {
  const DashedCircleBorder({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.5,
    required this.child,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: color, strokeWidth: strokeWidth),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color, required this.strokeWidth});

  static const _dashWidth = 4.0;
  static const _gapWidth = 3.0;

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (_dashWidth + _gapWidth)).floor();
    final dashAngle = _dashWidth / radius;
    final gapAngle = _gapWidth / radius;

    var startAngle = -pi / 2;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, dashAngle, false, paint);
      startAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
