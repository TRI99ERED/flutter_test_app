import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

const double radioButtonSmallSize = 0.8;
const double radioButtonMediumSize = 1.2;
const double radioButtonLargeSize = 1.6;

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final double size;

  const AppRadioButton({
    super.key,
    required this.value,
    this.size = radioButtonSmallSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: size,
      child: Radio<T>(
        value: value,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side:
            WidgetStateBorderSide.fromMap(<WidgetStatesConstraint, BorderSide?>{
              WidgetState.disabled: BorderSide(
                color: LightColor.medium.color,
                width: 1.5,
              ),
              WidgetState.selected: BorderSide(
                color: HighlightColor.darkest.color,
                width: 5.5,
              ),
              WidgetState.any: BorderSide(
                color: LightColor.darkest.color,
                width: 1.5,
              ),
            }),
        fillColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
          WidgetState.disabled: LightColor.medium.color,
          WidgetState.selected: HighlightColor.darkest.color,
          WidgetState.any: LightColor.lightest.color,
        }),
        innerRadius: WidgetStatePropertyAll(0),
      ),
    );
  }
}
