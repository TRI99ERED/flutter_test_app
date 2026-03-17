import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

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
  late ValueNotifier<int> _value;

  @override
  void initState() {
    super.initState();
    _value = ValueNotifier<int>(widget.value);
  }

  @override
  void didUpdateWidget(AppNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value.value = widget.value;
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
                  (widget.min == null || _value.value > widget.min!) &&
                      widget.enabled
                  ? () {
                      --_value.value;
                      if (widget.onChanged != null) {
                        widget.onChanged!(_value.value);
                      }
                    }
                  : null,
              icon: Icon(AppIcons.minus),
              iconSize: 8,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.highlightDarkestColor,
                backgroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.highlightLightestColor,
                disabledBackgroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundStrongColor,
                disabledForegroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundWeakestColor,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: spacing40),
            child: ValueListenableBuilder<int>(
              valueListenable: _value,
              builder: (context, value, _) {
                return Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.enabled
                        ? widget.textColor ??
                              Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongestColor
                        : Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundWeakColor,
                    fontSize: bMSize,
                    fontWeight: bMWeight,
                  ),
                );
              },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: spacing24,
              maxHeight: spacing24,
            ),
            child: IconButton(
              onPressed:
                  (widget.max == null || _value.value < widget.max!) &&
                      widget.enabled
                  ? () {
                      ++_value.value;
                      if (widget.onChanged != null) {
                        widget.onChanged!(_value.value);
                      }
                    }
                  : null,
              icon: Icon(AppIcons.add),
              iconSize: 8,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.highlightDarkestColor,
                backgroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.highlightLightestColor,
                disabledBackgroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundStrongColor,
                disabledForegroundColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundWeakestColor,
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
                    ? Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongColor
                    : Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundWeakestColor,
                fontSize: h5Size,
                fontWeight: h5Weight,
              ),
            ),
            if (supportText != null)
              Text(
                supportText!,
                style: TextStyle(
                  color: enabled
                      ? Theme.of(context).extension<AppTheme>()?.errorDarkColor
                      : Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundWeakestColor,
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
          textColor: supportText != null
              ? Theme.of(context).extension<AppTheme>()?.errorDarkColor
              : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
