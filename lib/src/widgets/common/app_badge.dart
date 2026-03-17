import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppBadgeSymbol extends StatelessWidget {
  final double size;
  final String symbol;

  const AppBadgeSymbol({super.key, required this.symbol, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppTheme>()?.highlightDarkestColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: cMSize,
            fontWeight: cMWeight,
            color: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongestColor,
          ),
        ),
      ),
    );
  }
}

class AppBadgeIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const AppBadgeIcon({super.key, required this.icon, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppTheme>()?.highlightDarkestColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Theme.of(
            context,
          ).extension<AppTheme>()?.backgroundStrongestColor,
          size: cMSize,
        ),
      ),
    );
  }
}

class AppBadgeEmpty extends StatelessWidget {
  final double size;

  const AppBadgeEmpty({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppTheme>()?.highlightDarkestColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
