import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_badge.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_toggle.dart';
import 'package:test_app/src/features/themes/styles.dart';

enum AppListItemControl {
  none,
  smallButton,
  largeButton,
  toggle,
  checkbox,
  badge,
}

class AppListItem extends StatelessWidget {
  final String? title;
  final String? description;
  final IconData? icon;
  final Widget? avatar;
  final bool? value;
  final String? symbol;
  final String? largeButtonText;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onChanged;
  final AppListItemControl control;

  const AppListItem({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.avatar,
    this.value,
    this.symbol,
    this.largeButtonText,
    this.onPressed,
    this.onChanged,
    this.control = AppListItemControl.none,
  }) : assert(
         control != AppListItemControl.smallButton || onPressed != null,
         'If control is smallButton, onPressed must be provided',
       ),
       assert(
         control != AppListItemControl.largeButton || onPressed != null,
         'If control is largeButton, onPressed must be provided',
       ),
       assert(
         (control == AppListItemControl.toggle ||
                 control == AppListItemControl.checkbox)
             ? onChanged != null
             : true,
         'If control is toggle or checkbox, onChanged must be provided',
       ),
       assert(
         control != AppListItemControl.badge || symbol != null,
         'If control is badge, symbol must be provided',
       ),
       assert(
         (icon != null || avatar != null) ||
             (title != null || description != null),
         'If no icon or avatar is provided, title or description must be provided',
       ),
       assert(
         !(icon != null && avatar != null),
         'Cannot provide both icon and avatar',
       );

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: switch (control) {
        AppListItemControl.smallButton => onPressed,
        AppListItemControl.largeButton => onPressed,
        AppListItemControl.toggle => () {
          onPressed?.call();
          onChanged?.call(!(value ?? false));
        },
        AppListItemControl.checkbox => () {
          onPressed?.call();
          onChanged?.call(!(value ?? false));
        },
        AppListItemControl.badge => onPressed,
        AppListItemControl.none => onPressed,
      },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.highlightDarkestColor,
            ),
          if (avatar != null)
            Padding(
              padding: EdgeInsets.only(right: spacing8),
              child: avatar,
            ),
          SizedBox(width: spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: bMSize,
                      fontWeight: bMWeight,
                      color: Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongestColor,
                    ),
                  ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: bSSize,
                      fontWeight: bSWeight,
                      color: Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundWeakColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                    softWrap: true,
                  ),
              ],
            ),
          ),
          switch (control) {
            AppListItemControl.smallButton => IconButton(
              onPressed: onPressed,
              icon: Icon(
                AppIcons.arrowRight,
                size: 12,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundWeakestColor,
              ),
            ),
            AppListItemControl.largeButton => AppButtonSecondary(
              text: largeButtonText,
              onPressed: onPressed,
            ),
            AppListItemControl.toggle => AppToggle(
              value: value ?? false,
              onChanged: (value) {
                onPressed?.call();
                onChanged?.call(value);
              },
            ),
            AppListItemControl.checkbox => AppCheckbox(
              value: value ?? false,
              onChanged: (value) {
                onPressed?.call();
                onChanged?.call(value ?? false);
              },
              size: checkboxMediumSize,
            ),
            AppListItemControl.badge => IconButton(
              onPressed: onPressed,
              icon: AppBadgeSymbol(symbol: symbol ?? ''),
            ),
            AppListItemControl.none => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}
