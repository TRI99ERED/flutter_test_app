import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppTabs extends StatefulWidget {
  final int tabCount;
  final List<String> tabTitles;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const AppTabs({
    super.key,
    required this.tabCount,
    required this.tabTitles,
    this.selectedIndex = 0,
    this.onTabSelected,
  }) : assert(tabCount > 1, 'tabCount must be greater than 1'),
       assert(
         tabTitles.length == tabCount,
         'tabTitles length must be equal to tabCount',
       );

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(AppTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(widget.tabCount, (index) {
          return Expanded(
            child: _Tab(
              text: widget.tabTitles[index],
              onPressed: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (widget.onTabSelected != null) {
                  widget.onTabSelected!(index);
                }
              },
              selected: index == _selectedIndex,
            ),
          );
        }),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool selected;

  const _Tab({required this.text, this.onPressed, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? DarkColor.darkest.color
            : DarkColor.light.color,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Column(
        children: [
          Text(text),
          selected
              ? Container(
                  margin: EdgeInsets.only(top: spacing4),
                  width: 24,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HighlightColor.darkest.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : SizedBox(height: spacing8),
        ],
      ),
    );
  }
}
