import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final int? steps;

  const AppProgressBar({super.key, required this.value, this.steps})
    : assert(value >= 0 && value <= 1, 'Value must be between 0 and 1'),
      assert(
        steps == null || steps > 0,
        'Steps must be greater than 0 if provided',
      );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 8),
      painter: _AppProgressBarPainter(value: value, steps: steps),
    );
  }
}

class _AppProgressBarPainter extends CustomPainter {
  final double _value;
  final int? _steps;

  _AppProgressBarPainter({required double value, int? steps})
    : _value = value,
      _steps = steps,
      assert(value >= 0 && value <= 1, 'Value must be between 0 and 1'),
      assert(
        steps == null || steps > 0,
        'Steps must be greater than 0 if provided',
      );

  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = LightColor.medium.color
      ..strokeWidth = size.height;

    final trackPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = HighlightColor.darkest.color
      ..strokeWidth = size.height;

    if (_steps == null) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), railPaint);

      if (_value > 0) {
        canvas.drawLine(
          Offset.zero,
          Offset(size.width * _value, 0),
          trackPaint,
        );
      }
    } else {
      final gapWidth = spacing12;
      final totalGapWidth = (_steps - 1) * gapWidth;
      final stepWidth = (size.width - totalGapWidth) / _steps;
      final fillProgress = _value * _steps;

      for (int i = 0; i < _steps; ++i) {
        final startX = i * (stepWidth + gapWidth);
        final stepEnd = i + 1;

        if (fillProgress >= stepEnd) {
          canvas.drawLine(
            Offset(startX, 0),
            Offset(startX + stepWidth, 0),
            trackPaint,
          );
        } else if (fillProgress > i) {
          final fillAmount = fillProgress - i;
          canvas.drawLine(
            Offset(startX, 0),
            Offset(startX + stepWidth, 0),
            railPaint,
          );
          canvas.drawLine(
            Offset(startX, 0),
            Offset(startX + stepWidth * fillAmount, 0),
            trackPaint,
          );
        } else {
          canvas.drawLine(
            Offset(startX, 0),
            Offset(startX + stepWidth, 0),
            railPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_AppProgressBarPainter oldDelegate) {
    return oldDelegate._value != _value || oldDelegate._steps != _steps;
  }
}
