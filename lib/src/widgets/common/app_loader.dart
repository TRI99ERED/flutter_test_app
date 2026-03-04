import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppLoader extends StatelessWidget {
  final double value;

  const AppLoader({super.key, required this.value})
    : assert(value >= 0 && value <= 1, 'Value must be between 0 and 1');

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        size: const Size(double.infinity, 8),
        painter: _AppLoaderPainter(value: value),
      ),
    );
  }
}

class _AppLoaderPainter extends CustomPainter {
  final double _value;

  _AppLoaderPainter({required double value})
    : _value = value,
      assert(value >= 0 && value <= 1, 'Value must be between 0 and 1');

  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = LightColor.medium.color
      ..strokeWidth = 5;

    final trackPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = HighlightColor.darkest.color
      ..strokeWidth = 5;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      0,
      pi * 2,
      false,
      railPaint,
    );

    if (_value > 0) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        -pi / 2,
        pi * 2 * _value,
        false,
        trackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_AppLoaderPainter oldDelegate) {
    return oldDelegate._value != _value;
  }
}
