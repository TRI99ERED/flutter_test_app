import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

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
      _selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(widget.tabCount, (index) {
          return Expanded(
            child: _TabItem(
              text: widget.tabTitles[index],
              icon: widget.tabIcons[index],
              onPressed: () {
                _selectedIndex = index;
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
        padding: EdgeInsets.zero,
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCrossFade(
            crossFadeState: selected
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            firstChild: Icon(
              icon,
              size: 20,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.highlightDarkestColor,
            ),
            secondChild: Icon(
              icon,
              size: 20,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundWeakColor,
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: selected
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            firstChild: Text(
              text,
              style: TextStyle(
                fontSize: bXSSize,
                fontWeight: bXSWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            secondChild: Text(
              text,
              style: TextStyle(
                fontSize: bXSSize,
                fontWeight: bXSWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundWeakColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
