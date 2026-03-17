import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppTooltip extends StatelessWidget {
  final bool isTop;
  final double horizontalOffset;
  final String? title;
  final String? description;

  AppTooltip({
    super.key,
    required this.isTop,
    required this.horizontalOffset,
    this.title,
    this.description,
  }) : assert(
         horizontalOffset >= 0.0 && horizontalOffset <= 1.0,
         'horizontalOffset must be between 0.0 and 1.0',
       ) {
    assert(
      (title?.trim().isNotEmpty ?? false) ||
          (description?.trim().isNotEmpty ?? false),
      'At least one of title or description must be a non-empty string',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = title?.trim().isNotEmpty ?? false;
    final hasDescription = description?.trim().isNotEmpty ?? false;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 112),
        child: CustomPaint(
          painter: _TooltipTipPainter(
            context: context,
            isTop: isTop,
            horizontalOffset: horizontalOffset,
          ),
          child: Column(
            children: [
              if (isTop) SizedBox(height: spacing10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(spacing8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundStrongColor,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasTitle)
                          Text(
                            title!.trim(),
                            style: TextStyle(
                              fontSize: h5Size,
                              fontWeight: h5Weight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                            ),
                          ),
                        if (hasTitle && hasDescription)
                          SizedBox(height: spacing8),
                        if (hasDescription)
                          Text(
                            description!.trim(),
                            style: TextStyle(
                              fontSize: bXSSize,
                              fontWeight: bXSWeight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isTop) SizedBox(height: spacing10),
            ],
          ),
        ),
      ),
    );
  }
}

class _TooltipTipPainter extends CustomPainter {
  final BuildContext context;
  final bool isTop;
  final double horizontalOffset;

  _TooltipTipPainter({
    required this.context,
    required this.isTop,
    required this.horizontalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          Theme.of(context).extension<AppTheme>()?.foregroundStrongColor ??
          const Color(0xF8F9FEFF);
    final path = Path();

    const triangleWidth = 20.0;
    const triangleHeight = 10.0;
    const containerPadding = 8.0;

    final containerStart = containerPadding + triangleWidth / 2;
    final containerEnd = size.width - containerPadding - triangleWidth / 2;

    final normalizedOffset = horizontalOffset.clamp(0.0, 1.0).toDouble();
    final actualOffset =
        containerStart + (normalizedOffset * (containerEnd - containerStart));

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
