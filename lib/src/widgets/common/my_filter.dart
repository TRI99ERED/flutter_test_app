import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/my_badge.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyFilter extends StatelessWidget {
  final bool showIcon;
  final int filteredItemCount;
  final VoidCallback? onPressed;

  const MyFilter({
    super.key,
    this.showIcon = true,
    this.filteredItemCount = 0,
    this.onPressed,
  });

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
            if (showIcon) const SizedBox(width: 8),
            Text('Filter', style: TextStyle(color: DarkColor.darkest.color)),
            const SizedBox(width: 12),
            if (filteredItemCount == 0)
              Icon(
                AppIcons.arrowDown,
                size: 10,
                color: LightColor.darkest.color,
              ),
            if (filteredItemCount > 0)
              MyBadgeSymbol(symbol: filteredItemCount.toString(), size: 20),
          ],
        ),
      ),
    );
  }
}
