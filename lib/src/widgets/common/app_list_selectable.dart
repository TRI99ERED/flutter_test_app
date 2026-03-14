import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppListSelectable extends StatelessWidget {
  final String title;
  final bool? value;
  final VoidCallback? onPressed;
  final ValueChanged<bool?>? onChanged;

  const AppListSelectable({
    super.key,
    required this.title,
    this.value,
    this.onPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: () {
          onPressed?.call();
          onChanged?.call(!(value ?? false));
        },
        style: TextButton.styleFrom(
          backgroundColor: (value ?? false)
              ? HighlightColor.lightest.color
              : LightColor.lightest.color,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: DarkColor.darkest.color,
                ),
              ),
            ),
            if (value == true)
              Icon(
                AppIcons.check,
                size: 12,
                color: HighlightColor.darkest.color,
              ),
          ],
        ),
      ),
    );
  }
}
