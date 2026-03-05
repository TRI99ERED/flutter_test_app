import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppNumberInput extends StatefulWidget {
  final int value;
  final int? min;
  final int? max;
  final bool enabled;
  final Color? textColor;
  final ValueChanged<int>? onChanged;

  const AppNumberInput({
    super.key,
    required this.value,
    this.min,
    this.max,
    this.enabled = true,
    this.textColor,
    this.onChanged,
  }) : assert(
         min == null || max == null || min <= max,
         'min must be less than or equal to max',
       );

  @override
  State<AppNumberInput> createState() => _AppNumberInputState();
}

class _AppNumberInputState extends State<AppNumberInput> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(AppNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: spacing8,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: spacing24,
              maxHeight: spacing24,
            ),
            child: IconButton(
              onPressed:
                  (widget.min == null || _value > widget.min!) && widget.enabled
                  ? () {
                      setState(() {
                        --_value;
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!(_value);
                      }
                    }
                  : null,
              icon: Icon(AppIcons.minus),
              iconSize: 8,
              style: IconButton.styleFrom(
                foregroundColor: HighlightColor.darkest.color,
                backgroundColor: HighlightColor.lightest.color,
                disabledBackgroundColor: LightColor.light.color,
                disabledForegroundColor: LightColor.darkest.color,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: spacing40),
            child: Text(
              '$_value',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.enabled
                    ? widget.textColor ?? DarkColor.darkest.color
                    : DarkColor.light.color,
                fontSize: bMSize,
                fontWeight: bMWeight,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: spacing24,
              maxHeight: spacing24,
            ),
            child: IconButton(
              onPressed:
                  (widget.max == null || _value < widget.max!) && widget.enabled
                  ? () {
                      setState(() {
                        ++_value;
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!(_value);
                      }
                    }
                  : null,
              icon: Icon(AppIcons.add),
              iconSize: 8,
              style: IconButton.styleFrom(
                foregroundColor: HighlightColor.darkest.color,
                backgroundColor: HighlightColor.lightest.color,
                disabledBackgroundColor: LightColor.light.color,
                disabledForegroundColor: LightColor.darkest.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppNumberInputTitled extends StatelessWidget {
  final int value;
  final int? min;
  final int? max;
  final bool enabled;
  final String title;
  final String? supportText;
  final ValueChanged<int>? onChanged;

  const AppNumberInputTitled({
    super.key,
    required this.value,
    this.min,
    this.max,
    this.enabled = true,
    required this.title,
    this.supportText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: enabled
                    ? DarkColor.dark.color
                    : DarkColor.lightest.color,
                fontSize: h5Size,
                fontWeight: h5Weight,
              ),
            ),
            if (supportText != null)
              Text(
                supportText!,
                style: TextStyle(
                  color: enabled
                      ? ErrorColor.dark.color
                      : DarkColor.lightest.color,
                  fontSize: bSSize,
                  fontWeight: bSWeight,
                ),
              ),
          ],
        ),
        AppNumberInput(
          value: value,
          min: min,
          max: max,
          enabled: enabled,
          textColor: supportText != null ? ErrorColor.dark.color : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
