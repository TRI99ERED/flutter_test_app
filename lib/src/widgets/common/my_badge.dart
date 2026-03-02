import 'package:flutter/widgets.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyBadgeSymbol extends StatefulWidget {
  final double size;
  final String symbol;

  const MyBadgeSymbol({super.key, required this.symbol, this.size = 24});

  @override
  State<MyBadgeSymbol> createState() => _MyBadgeSymbolState();
}

class _MyBadgeSymbolState extends State<MyBadgeSymbol> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.symbol,
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

class MyBadgeIcon extends StatefulWidget {
  final double size;
  final IconData icon;

  const MyBadgeIcon({super.key, required this.icon, this.size = 24});

  @override
  State<MyBadgeIcon> createState() => _MyBadgeIconState();
}

class _MyBadgeIconState extends State<MyBadgeIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: LightColor.lightest.color,
          size: cMSize,
        ),
      ),
    );
  }
}

class MyBadgeEmpty extends StatefulWidget {
  final double size;

  const MyBadgeEmpty({super.key, this.size = 24});

  @override
  State<MyBadgeEmpty> createState() => _MyBadgeEmptyState();
}

class _MyBadgeEmptyState extends State<MyBadgeEmpty> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: HighlightColor.darkest.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
