import 'package:flutter/widgets.dart';
import 'package:test_app/src/widgets/common/styles.dart';

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
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: cMSize,
            fontWeight: cMWeight,
            color: LightColor.lightest.color,
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
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: LightColor.lightest.color, size: cMSize),
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
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
    );
  }
}

