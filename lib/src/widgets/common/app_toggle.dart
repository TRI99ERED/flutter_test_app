import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      trackOutlineColor:
          WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
            WidgetState.disabled: LightColor.medium.color,
            WidgetState.selected: HighlightColor.darkest.color,
            WidgetState.any: LightColor.dark.color,
          }),
      trackOutlineWidth: const WidgetStatePropertyAll(0),
      trackColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
        WidgetState.disabled: LightColor.medium.color,
        WidgetState.selected: HighlightColor.darkest.color,
        WidgetState.any: LightColor.dark.color,
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
        WidgetState.disabled: LightColor.light.color,
        WidgetState.selected: LightColor.lightest.color,
        WidgetState.any: LightColor.lightest.color,
      }),
      thumbIcon: WidgetStatePropertyAll(
        Icon(Icons.circle, size: 20, color: LightColor.lightest.color),
      ),
    );
  }
}
