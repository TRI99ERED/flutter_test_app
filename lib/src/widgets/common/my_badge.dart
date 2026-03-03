import 'package:flutter/widgets.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyBadgeSymbol extends StatelessWidget {
  final double size;
  final String symbol;

  const MyBadgeSymbol({super.key, required this.symbol, this.size = 24});

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

class MyBadgeIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const MyBadgeIcon({super.key, required this.icon, this.size = 24});

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

class MyBadgeEmpty extends StatelessWidget {
  final double size;

  const MyBadgeEmpty({super.key, this.size = 24});

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
