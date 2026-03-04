import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

Widget _buildButtonContent({
  String? text,
  IconData? leftIcon,
  IconData? rightIcon,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leftIcon != null) Icon(leftIcon),
      if (leftIcon != null && text != null) SizedBox(width: spacing8),
      if (text != null)
        Text(
          text,
          style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
        ),
      if (rightIcon != null && (text != null || leftIcon != null))
        SizedBox(width: spacing8),
      if (rightIcon != null) Icon(rightIcon),
    ],
  );
}

class AppButtonPrimary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const AppButtonPrimary({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: HighlightColor.darkest.color,
        foregroundColor: HighlightColor.lightest.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildButtonContent(
        text: text,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
      ),
    );
  }
}

class AppButtonSecondary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const AppButtonSecondary({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: LightColor.lightest.color,
        foregroundColor: HighlightColor.darkest.color,
        side: BorderSide(color: HighlightColor.darkest.color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildButtonContent(
        text: text,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
      ),
    );
  }
}

class AppButtonTertiary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const AppButtonTertiary({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: HighlightColor.darkest.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildButtonContent(
        text: text,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
      ),
    );
  }
}
