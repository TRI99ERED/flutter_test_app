import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/my_button.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyBanner extends StatefulWidget {
  final String? title;
  final String? description;
  final VoidCallback? onPressed;
  final String? buttonText;
  final Widget? image;

  const MyBanner({
    super.key,
    this.title,
    this.description,
    this.onPressed,
    this.buttonText,
    this.image,
  });

  @override
  State<MyBanner> createState() => _MyBannerState();
}

class _MyBannerState extends State<MyBanner> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 160),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: HighlightColor.lightest.color,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: h4Size,
                      fontWeight: h4Weight,
                    ),
                  ),
                if (widget.title != null) const SizedBox(height: 8),
                if (widget.description != null)
                  Text(
                    widget.description!,
                    style: const TextStyle(
                      fontSize: bSSize,
                      fontWeight: bSWeight,
                    ),
                    softWrap: true,
                  ),
                if (widget.description != null) const SizedBox(height: 8),
                if (widget.buttonText != null)
                  MyButtonPrimary(
                    onPressed: widget.onPressed,
                    text: widget.buttonText!,
                  ),
              ],
            ),
            if (widget.image != null) widget.image!,
          ],
        ),
      ),
    );
  }
}
