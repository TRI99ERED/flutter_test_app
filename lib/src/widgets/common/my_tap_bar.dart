import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyTapBar extends StatefulWidget {
  final int tabCount;
  final List<String> tabTitles;
  final List<IconData> tabIcons;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const MyTapBar({
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
       );

  @override
  State<MyTapBar> createState() => _MyTapBarState();
}

class _MyTapBarState extends State<MyTapBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 332,
      height: 39,
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 4,
        children: List.generate(widget.tabCount, (index) {
          return Expanded(
            child: _MyTab(
              text: widget.tabTitles.length > index
                  ? widget.tabTitles[index]
                  : 'Tab ${index + 1}',
              icon: widget.tabIcons.length > index
                  ? widget.tabIcons[index]
                  : AppIcons.record,
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

class _MyTab extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final bool selected;

  const _MyTab({
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
          if (!selected) const SizedBox(height: 4),
        ],
      ),
    );
  }
}
