import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/app_badge.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppAccordion extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final int selectedCount;
  final ValueChanged<bool>? onExpansionChanged;

  const AppAccordion({
    super.key,
    required this.title,
    required this.children,
    this.selectedCount = 0,
    this.onExpansionChanged,
  });

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion> {
  bool _isExpanded = false;

  void _handleExpansionChanged(bool expanded) {
    _isExpanded = expanded;
    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: bMSize,
              fontWeight: bMWeight,
              color: DarkColor.darkest.color,
            ),
          ),
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
          tilePadding: EdgeInsets.zero,
          minTileHeight: 0,
          trailing: widget.selectedCount == 0
              ? Icon(
                  _isExpanded ? AppIcons.arrowUp : AppIcons.arrowDown,
                  size: 12,
                  color: DarkColor.lightest.color,
                )
              : AppBadgeSymbol(
                  symbol: widget.selectedCount.toString(),
                  size: 24,
                ),
          onExpansionChanged: _handleExpansionChanged,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          childrenPadding: EdgeInsets.zero,
          children: widget.children,
        ),
        const AppDivider(),
      ],
    );
  }
}

class AppAccordionText extends StatelessWidget {
  final String text;

  const AppAccordionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: bSSize,
        fontWeight: bSWeight,
        color: DarkColor.light.color,
      ),
    );
  }
}
