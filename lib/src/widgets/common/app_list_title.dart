import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppListTitle extends StatelessWidget {
  final String title;
  final String? buttonText;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AppListTitle({
    super.key,
    required this.title,
    this.buttonText,
    this.icon,
    this.onPressed,
  }) : assert(
         buttonText == null || icon == null,
         'If buttonText is provided, icon cannot be provided, and vice versa',
       ),
       assert(
         buttonText == null || onPressed != null,
         'If buttonText is provided, onPressed must also be provided',
       ),
       assert(
         icon == null || onPressed != null,
         'If icon is provided, onPressed must also be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
      color: LightColor.lightest.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: h4Size,
              fontWeight: h4Weight,
              color: DarkColor.darkest.color,
              fontFamily: GoogleFonts.inter().fontFamily,
              decoration: TextDecoration.none,
            ),
          ),
          if (buttonText != null && onPressed != null && icon == null)
            AppButtonTertiary(onPressed: onPressed, text: buttonText!),
          if (buttonText == null && onPressed != null && icon != null)
            IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: 16, color: DarkColor.lightest.color),
            ),
        ],
      ),
    );
  }
}
