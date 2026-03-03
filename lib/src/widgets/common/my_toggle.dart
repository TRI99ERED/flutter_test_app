import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const MyToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      trackOutlineColor:
          WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
            WidgetState.selected: HighlightColor.darkest.color,
            WidgetState.any: LightColor.dark.color,
          }),
      trackOutlineWidth: WidgetStatePropertyAll(0),
      activeTrackColor: HighlightColor.darkest.color,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStatePropertyAll(LightColor.lightest.color),
      thumbIcon: WidgetStatePropertyAll(
        Icon(Icons.circle, size: 20, color: LightColor.lightest.color),
      ),
    );
  }
}
