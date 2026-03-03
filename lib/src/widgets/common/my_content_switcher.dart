import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyContentSwitcher extends StatefulWidget {
  final int sectionCount;
  final List<String> sectionTitles;
  final int selectedIndex;
  final ValueChanged<int>? onSectionSelected;

  const MyContentSwitcher({
    super.key,
    required this.sectionCount,
    required this.sectionTitles,
    this.selectedIndex = 0,
    this.onSectionSelected,
  }) : assert(sectionCount > 1, 'sectionCount must be greater than 1'),
       assert(
         sectionTitles.length == sectionCount,
         'sectionTitles length must be equal to sectionCount',
       );

  @override
  State<MyContentSwitcher> createState() => _MyContentSwitcherState();
}

class _MyContentSwitcherState extends State<MyContentSwitcher> {
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
        color: LightColor.light.color,
        borderRadius: BorderRadius.circular(16),
      ),
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
            child: _MySection(
              text: widget.sectionTitles.length > index ~/ 2
                  ? widget.sectionTitles[index ~/ 2]
                  : 'Section ${index ~/ 2 + 1}',
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
          );
        }),
      ),
    );
  }
}

class _MySection extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool selected;

  const _MySection({required this.text, this.onPressed, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: selected ? LightColor.lightest.color : null,
        foregroundColor: selected
            ? DarkColor.darkest.color
            : DarkColor.light.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text),
    );
  }
}
