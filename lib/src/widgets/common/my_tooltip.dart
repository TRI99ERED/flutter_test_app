import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyTooltip extends StatelessWidget {
  final bool isTop;
  final double horizontalOffset;
  final String? title;
  final String? description;

  const MyTooltip({
    super.key,
    required this.isTop,
    required this.horizontalOffset,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 112),
        child: CustomPaint(
          painter: _TooltipTipPainter(
            isTop: isTop,
            horizontalOffset: horizontalOffset,
          ),
          child: Column(
            children: [
              if (isTop) const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: DarkColor.dark.color,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: h5Size,
                            fontWeight: h5Weight,
                            color: LightColor.lightest.color,
                          ),
                        ),
                      if (title != null) const SizedBox(height: 8),
                      if (description != null)
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: bXSSize,
                            fontWeight: bXSWeight,
                            color: LightColor.lightest.color,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!isTop) const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _TooltipTipPainter extends CustomPainter {
  final bool isTop;
  final double horizontalOffset;

  _TooltipTipPainter({required this.isTop, required this.horizontalOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = DarkColor.dark.color;
    final path = Path();

    const triangleWidth = 20.0;
    const triangleHeight = 10.0;
    const containerPadding = 8.0;

    // The container starts at triangleHeight (top) or 0 (bottom)
    // and has width = size.width
    final containerStart = containerPadding + triangleWidth / 2;
    final containerEnd = size.width - containerPadding - triangleWidth / 2;

    // Map normalized offset (0.0 to 1.0) to the valid range
    final actualOffset =
        containerStart + (horizontalOffset * (containerEnd - containerStart));

    if (isTop) {
      path.moveTo(actualOffset, 0);
      path.lineTo(actualOffset - triangleWidth / 2, triangleHeight);
      path.lineTo(actualOffset + triangleWidth / 2, triangleHeight);
    } else {
      path.moveTo(
        actualOffset - triangleWidth / 2,
        size.height - triangleHeight,
      );
      path.lineTo(
        actualOffset + triangleWidth / 2,
        size.height - triangleHeight,
      );
      path.lineTo(actualOffset, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipTipPainter oldDelegate) =>
      oldDelegate.isTop != isTop ||
      oldDelegate.horizontalOffset != horizontalOffset;
}
