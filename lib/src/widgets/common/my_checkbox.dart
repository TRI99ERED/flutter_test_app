import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

const double checkboxSmallSize = 0.8;
const double checkboxMediumSize = 1.2;
const double checkboxLargeSize = 1.6;

class MyCheckbox extends StatelessWidget {
  final bool value;
  final double size;
  final ValueChanged<bool?>? onChanged;

  const MyCheckbox({
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
        fillColor: value
            ? WidgetStateProperty.all(HighlightColor.darkest.color)
            : null,
        checkColor: LightColor.lightest.color,
        side: BorderSide(color: LightColor.darkest.color, width: 1.5),
      ),
    );
  }
}
