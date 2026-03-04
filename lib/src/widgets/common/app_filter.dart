import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/app_badge.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppFilter extends StatelessWidget {
  final bool showIcon;
  final int filteredItemCount;
  final VoidCallback? onPressed;

  const AppFilter({
    super.key,
    this.showIcon = true,
    this.filteredItemCount = 0,
    this.onPressed,
  }) : assert(
         filteredItemCount >= 0,
         'filteredItemCount must be greater than or equal to 0',
       );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: LightColor.darkest.color, width: 0.5),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon)
              Icon(AppIcons.filter, size: 12, color: LightColor.darkest.color),
            if (showIcon) SizedBox(width: spacing8),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: bSSize,
                fontWeight: bSWeight,
                color: DarkColor.darkest.color,
              ),
            ),
            SizedBox(width: spacing12),
            if (filteredItemCount == 0)
              Icon(
                AppIcons.arrowDown,
                size: 10,
                color: LightColor.darkest.color,
              ),
            if (filteredItemCount > 0)
              AppBadgeSymbol(symbol: filteredItemCount.toString(), size: 20),
          ],
        ),
      ),
    );
  }
}
