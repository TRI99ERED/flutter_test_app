import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppContentSwitcher extends StatefulWidget {
  final int sectionCount;
  final List<String> sectionTitles;
  final int selectedIndex;
  final ValueChanged<int>? onSectionSelected;

  const AppContentSwitcher({
    super.key,
    required this.sectionCount,
    required this.sectionTitles,
    this.selectedIndex = 0,
    this.onSectionSelected,
  }) : assert(sectionCount > 1, 'sectionCount must be greater than 1'),
       assert(
         sectionTitles.length == sectionCount,
         'sectionTitles length must be equal to sectionCount',
       ),
       assert(
         selectedIndex >= 0 && selectedIndex < sectionCount,
         'selectedIndex must be between 0 and sectionCount - 1',
       );

  @override
  State<AppContentSwitcher> createState() => _AppContentSwitcherState();
}

class _AppContentSwitcherState extends State<AppContentSwitcher> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant AppContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.light.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(widget.sectionCount * 2 - 1, (index) {
            if (index.isOdd) {
              return VerticalDivider(
                color: LightColor.darkest.color,
                indent: 9.5,
                endIndent: 9.5,
                thickness: 1,
              );
            }
            return Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing4),
                child: _AppSection(
                  text: widget.sectionTitles[index ~/ 2],
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index ~/ 2;
                    });
                    if (widget.onSectionSelected != null) {
                      widget.onSectionSelected!(index ~/ 2);
                    }
                  },
                  selected: index ~/ 2 == _selectedIndex,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AppSection extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool selected;

  const _AppSection({
    required this.text,
    this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: spacing8, horizontal: 0),
        backgroundColor: selected ? LightColor.lightest.color : null,
        foregroundColor: selected
            ? DarkColor.darkest.color
            : DarkColor.light.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: h5Size, fontWeight: h5Weight),
      ),
    );
  }
}
