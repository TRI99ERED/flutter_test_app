import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppPaginationDots extends StatelessWidget {
  final int dotCount;
  final int activeIndex;

  const AppPaginationDots({
    super.key,
    required this.dotCount,
    required this.activeIndex,
  }) : assert(dotCount > 0, 'dotCount must be greater than 0'),
       assert(
         activeIndex >= 0 && activeIndex < dotCount,
         'activeIndex must be between 0 and dotCount - 1',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing8,
      children: List.generate(dotCount, (index) {
        return _AppPaginationDot(isActive: index == activeIndex);
      }),
    );
  }
}

class _AppPaginationDot extends StatelessWidget {
  final bool _isActive;

  const _AppPaginationDot({required bool isActive}) : _isActive = isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _isActive
            ? Theme.of(context).extension<AppTheme>()?.highlightDarkestColor
            : Theme.of(context).extension<AppTheme>()?.backgroundMediumColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
