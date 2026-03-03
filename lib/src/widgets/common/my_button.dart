import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyButtonPrimary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const MyButtonPrimary({
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null) Icon(leftIcon!),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (rightIcon != null) Icon(rightIcon!),
        ],
      ),
    );
  }
}

class MyButtonSecondary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const MyButtonSecondary({
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
        backgroundColor: HighlightColor.lightest.color,
        foregroundColor: HighlightColor.darkest.color,
        side: BorderSide(color: HighlightColor.darkest.color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null) Icon(leftIcon!),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (rightIcon != null) Icon(rightIcon!),
        ],
      ),
    );
  }
}

class MyButtonTertiary extends StatelessWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onPressed;

  const MyButtonTertiary({
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIcon != null) Icon(leftIcon!),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (rightIcon != null) Icon(rightIcon!),
        ],
      ),
    );
  }
}
