import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyButtonPrimary extends StatefulWidget {
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
  State<MyButtonPrimary> createState() => _MyButtonPrimaryState();
}

class _MyButtonPrimaryState extends State<MyButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: HighlightColor.darkest.color,
        foregroundColor: HighlightColor.lightest.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leftIcon != null) Icon(widget.leftIcon!),
          if (widget.text != null)
            Text(
              widget.text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (widget.rightIcon != null) Icon(widget.rightIcon!),
        ],
      ),
    );
  }
}

class MyButtonSecondary extends StatefulWidget {
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
  State<MyButtonSecondary> createState() => _MyButtonSecondaryState();
}

class _MyButtonSecondaryState extends State<MyButtonSecondary> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: HighlightColor.lightest.color,
        foregroundColor: HighlightColor.darkest.color,
        side: BorderSide(color: HighlightColor.darkest.color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leftIcon != null) Icon(widget.leftIcon!),
          if (widget.text != null)
            Text(
              widget.text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (widget.rightIcon != null) Icon(widget.rightIcon!),
        ],
      ),
    );
  }
}

class MyButtonTertiary extends StatefulWidget {
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
  State<MyButtonTertiary> createState() => _MyButtonTertiaryState();
}

class _MyButtonTertiaryState extends State<MyButtonTertiary> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: HighlightColor.darkest.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leftIcon != null) Icon(widget.leftIcon!),
          if (widget.text != null)
            Text(
              widget.text!,
              style: const TextStyle(fontSize: aMSize, fontWeight: aMWeight),
            ),
          if (widget.rightIcon != null) Icon(widget.rightIcon!),
        ],
      ),
    );
  }
}
