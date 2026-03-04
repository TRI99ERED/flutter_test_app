import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

const double checkboxSmallSize = 0.8;
const double checkboxMediumSize = 1.2;
const double checkboxLargeSize = 1.6;

class AppCheckbox extends StatelessWidget {
  final bool value;
  final double size;
  final ValueChanged<bool?>? onChanged;

  const AppCheckbox({
    super.key,
    required this.value,
    this.size = checkboxSmallSize,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: size,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
          WidgetState.disabled: LightColor.medium.color,
          WidgetState.selected: HighlightColor.darkest.color,
          WidgetState.any: LightColor.lightest.color,
        }),
        checkColor: LightColor.lightest.color,
        side: BorderSide(color: LightColor.darkest.color, width: 1.5),
      ),
    );
  }
}
