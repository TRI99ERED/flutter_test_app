import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? body;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.buttonText,
    this.onButtonPressed,
  }) : assert(
         (buttonText == null && onButtonPressed == null) ||
             (buttonText != null && onButtonPressed != null),
         'buttonText and onButtonPressed must both be provided or both be null',
       );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: spacing32,
        children: [
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const PlaceholderImage(),
            ),
          ),
          Column(
            spacing: spacing8,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: h2Size,
                  fontWeight: h2Weight,
                  color: DarkColor.darkest.color,
                ),
              ),
              if (body != null)
                Text(
                  body!,
                  style: TextStyle(
                    fontSize: bMSize,
                    fontWeight: bMWeight,
                    color: DarkColor.light.color,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          if (buttonText != null && onButtonPressed != null)
            AppButtonPrimary(onPressed: onButtonPressed, text: buttonText!),
        ],
      ),
    );
  }
}
