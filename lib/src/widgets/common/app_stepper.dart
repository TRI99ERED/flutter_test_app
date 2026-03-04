import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppStepper extends StatefulWidget {
  final int stepCount;
  final int currentStep;
  final List<String> stepTitles;
  final ValueChanged<int>? onStepTapped;

  const AppStepper({
    super.key,
    required this.stepCount,
    required this.currentStep,
    required this.stepTitles,
    this.onStepTapped,
  }) : assert(stepCount > 1, 'stepCount must be greater than 1'),
       assert(
         stepTitles.length == stepCount,
         'stepTitles length must be equal to stepCount',
       );

  @override
  State<AppStepper> createState() => _AppStepperState();
}

class _AppStepperState extends State<AppStepper> {
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.currentStep;
  }

  @override
  void didUpdateWidget(AppStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      setState(() {
        _currentStep = widget.currentStep;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(widget.stepCount, (index) {
        return _StepIndicator(
          text: widget.stepTitles[index],
          isCurrent: index == _currentStep,
          isDone: index < _currentStep,
          number: index + 1,
          onPressed: widget.onStepTapped != null
              ? () {
                  setState(() {
                    _currentStep = index;
                  });
                  widget.onStepTapped!(index);
                }
              : null,
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String text;
  final bool isCurrent;
  final bool isDone;
  final int? number;
  final VoidCallback? onPressed;

  const _StepIndicator({
    required this.text,
    this.isCurrent = false,
    this.isDone = false,
    this.number,
    this.onPressed,
  });

  Widget _buildStepContent() {
    return Column(
      children: [
        isDone || number == null
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: HighlightColor.light.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.check,
                  size: 10,
                  color: HighlightColor.darkest.color,
                ),
              )
            : Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? HighlightColor.darkest.color
                      : LightColor.light.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number!.toString(),
                    style: TextStyle(
                      fontSize: cMSize,
                      fontWeight: cMWeight,
                      color: isCurrent
                          ? LightColor.lightest.color
                          : DarkColor.lightest.color,
                    ),
                  ),
                ),
              ),
        Text(
          text,
          style: TextStyle(
            fontSize: h5Size,
            fontWeight: h5Weight,
            color: isCurrent
                ? DarkColor.darkest.color
                : DarkColor.lightest.color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: onPressed != null
          ? TextButton(
              onPressed: onPressed,
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              child: _buildStepContent(),
            )
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.zero,
              ),
              child: _buildStepContent(),
            ),
    );
  }
}
