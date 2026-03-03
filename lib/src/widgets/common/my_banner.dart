import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/my_button.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyBanner extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, minHeight: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: HighlightColor.lightest.color,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 8),
                    if (description != null)
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: bSSize,
                          fontWeight: bSWeight,
                        ),
                        softWrap: true,
                      ),
                    if (description != null) const SizedBox(height: 8),
                    if (buttonText != null)
                      MyButtonPrimary(onPressed: onPressed, text: buttonText!),
                  ],
                ),
              ),
              if (image != null)
                ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                    width: 100,
                    height: 100,
                  ),
                  child: image!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
