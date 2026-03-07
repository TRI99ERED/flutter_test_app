import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppTapBar extends StatefulWidget {
  final int tabCount;
  final List<String> tabTitles;
  final List<IconData> tabIcons;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const AppTapBar({
    super.key,
    required this.tabCount,
    required this.tabTitles,
    required this.tabIcons,
    this.selectedIndex = 0,
    this.onTabSelected,
  }) : assert(tabCount > 1, 'tabCount must be greater than 1'),
       assert(
         tabTitles.length == tabCount,
         'tabTitles length must be equal to tabCount',
       ),
       assert(
         tabIcons.length == tabCount,
         'tabIcons length must be equal to tabCount',
       );

  @override
  State<AppTapBar> createState() => _AppTapBarState();
}

class _AppTapBarState extends State<AppTapBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(AppTapBar oldWidget) {
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
      height: 88,
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        spacing: 4,
        children: List.generate(widget.tabCount, (index) {
          return Expanded(
            child: _TabItem(
              text: widget.tabTitles[index],
              icon: widget.tabIcons[index],
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

class _TabItem extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final bool selected;

  const _TabItem({
    required this.text,
    required this.icon,
    this.onPressed,
    this.selected = false,
  });

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: selected
                ? HighlightColor.darkest.color
                : DarkColor.light.color,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: bXSSize, fontWeight: bXSWeight),
          ),
        ],
      ),
    );
  }
}
