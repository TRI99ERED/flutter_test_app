import 'package:flutter/widgets.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppDialog2 extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final String? buttonText1;
  final String? buttonText2;

  const AppDialog2({
    super.key,
    this.title,
    this.description,
    this.onPressed1,
    this.onPressed2,
    this.buttonText1,
    this.buttonText2,
  }) : assert(
         (buttonText1 != null && onPressed1 != null) ||
             (buttonText1 == null && onPressed1 == null),
         'buttonText1 and onPressed1 must both be provided or both be null',
       ),
       assert(
         (buttonText2 != null && onPressed2 != null) ||
             (buttonText2 == null && onPressed2 == null),
         'buttonText2 and onPressed2 must both be provided or both be null',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing16),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: h3Size, fontWeight: h3Weight),
            ),
          if (title != null) const SizedBox(height: spacing8),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: bSSize, fontWeight: bSWeight),
            ),
          if (description != null) const SizedBox(height: spacing8),
          Row(
            children: [
              Expanded(
                child: AppButtonSecondary(
                  onPressed: onPressed1,
                  text: buttonText1,
                ),
              ),
              const SizedBox(width: spacing8),
              Expanded(
                child: AppButtonPrimary(
                  onPressed: onPressed2,
                  text: buttonText2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppDialog3 extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final VoidCallback? onPressed3;
  final String? buttonText1;
  final String? buttonText2;
  final String? buttonText3;

  const AppDialog3({
    super.key,
    this.title,
    this.description,
    this.onPressed1,
    this.onPressed2,
    this.onPressed3,
    this.buttonText1,
    this.buttonText2,
    this.buttonText3,
  }) : assert(
         (buttonText1 != null && onPressed1 != null) ||
             (buttonText1 == null && onPressed1 == null),
         'buttonText1 and onPressed1 must both be provided or both be null',
       ),
       assert(
         (buttonText2 != null && onPressed2 != null) ||
             (buttonText2 == null && onPressed2 == null),
         'buttonText2 and onPressed2 must both be provided or both be null',
       ),
       assert(
         (buttonText3 != null && onPressed3 != null) ||
             (buttonText3 == null && onPressed3 == null),
         'buttonText3 and onPressed3 must both be provided or both be null',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing16),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: h3Size, fontWeight: h3Weight),
            ),
          if (title != null) const SizedBox(height: spacing8),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: bSSize, fontWeight: bSWeight),
            ),
          if (description != null) const SizedBox(height: spacing8),
          AppButtonSecondary(onPressed: onPressed1, text: buttonText1),
          const SizedBox(height: spacing8),
          AppButtonSecondary(onPressed: onPressed2, text: buttonText2),
          const SizedBox(height: spacing8),
          AppButtonPrimary(onPressed: onPressed3, text: buttonText3),
        ],
      ),
    );
  }
}
