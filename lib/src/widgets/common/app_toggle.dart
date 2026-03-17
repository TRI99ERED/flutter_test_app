import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';

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
            WidgetState.disabled: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundMediumColor,
            WidgetState.selected: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkestColor,
            WidgetState.any: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundWeakColor,
          }),
      trackOutlineWidth: const WidgetStatePropertyAll(0),
      trackColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
        WidgetState.disabled: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundMediumColor,
        WidgetState.selected: Theme.of(
          context,
        ).extension<AppTheme>()?.highlightDarkestColor,
        WidgetState.any: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundWeakColor,
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
        WidgetState.disabled: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongColor,
        WidgetState.selected: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        WidgetState.any: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
      }),
      thumbIcon: WidgetStatePropertyAll(
        Icon(
          Icons.circle,
          size: 20,
          color: Theme.of(
            context,
          ).extension<AppTheme>()?.backgroundStrongestColor,
        ),
      ),
    );
  }
}
