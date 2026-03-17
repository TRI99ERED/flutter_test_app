import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';

class AppLoader extends StatefulWidget {
  final double? value;

  const AppLoader({super.key, this.value})
    : assert(
        value == null || (value >= 0 && value <= 1),
        'Value must be between 0 and 1',
      );

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: AspectRatio(
          aspectRatio: 1,
          child: widget.value == null
              ? AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: animationController.value * 2 * pi,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(32, 32),
                    painter: _AppLoaderPainter(context: context, end: 1 / 3),
                  ),
                )
              : CustomPaint(
                  size: const Size(32, 32),
                  painter: _AppLoaderPainter(
                    context: context,
                    end: widget.value!,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _AppLoaderPainter extends CustomPainter {
  final BuildContext context;
  final double _start;
  final double _end;

  _AppLoaderPainter({
    required this.context,
    double start = 0,
    required double end,
  }) : _start = start,
       _end = end,
       assert(start >= 0 && start <= 1, 'Start must be between 0 and 1'),
       assert(end >= 0 && end <= 1, 'End must be between 0 and 1');

  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color =
          Theme.of(context).extension<AppTheme>()?.backgroundMediumColor ??
          const Color(0xFFE8E9F1)
      ..strokeWidth = 5;

    final trackPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color =
          Theme.of(context).extension<AppTheme>()?.highlightDarkestColor ??
          const Color(0xFF006FFD)
      ..strokeWidth = 5;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      0,
      pi * 2,
      false,
      railPaint,
    );

    if (_end > 0) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        -pi / 2 + pi * 2 * _start,
        pi * 2 * (_end - _start),
        false,
        trackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_AppLoaderPainter oldDelegate) {
    return oldDelegate._end != _end;
  }
}
