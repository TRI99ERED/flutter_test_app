import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppTag extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool isSelected;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onChanged;

  const AppTag({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.isSelected = false,
    this.onPressed,
    this.onChanged,
  }) : assert(
         text != null || leftIcon != null || rightIcon != null,
         'At least one of text, leftIcon, or rightIcon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
        if (onChanged != null) {
          onChanged!(!isSelected);
        }
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing6),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isSelected) {
            return Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkestColor;
          }
          return Theme.of(
            context,
          ).extension<AppTheme>()?.highlightLightestColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (isSelected) {
            return Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongestColor;
          }
          return Theme.of(context).extension<AppTheme>()?.highlightDarkestColor;
        }),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(const StadiumBorder()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null) ...[
            Icon(leftIcon!, size: 16),
            if (text != null || rightIcon != null) SizedBox(width: spacing4),
          ],
          if (text != null) ...[
            Text(
              text!,
              style: const TextStyle(fontSize: cMSize, fontWeight: cMWeight),
            ),
            if (rightIcon != null) SizedBox(width: spacing4),
          ],
          if (rightIcon != null) Icon(rightIcon!, size: 16),
        ],
      ),
    );
  }
}
