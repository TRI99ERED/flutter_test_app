import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static void show({
    required BuildContext context,
    String? title,
    String? description,
    String? buttonText1,
    String? buttonText2,
    double width = 300,
    double height = 167,
    VoidCallback? onPressed1,
    VoidCallback? onPressed2,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) => Theme(
        data: Theme.of(context),
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: AppDialog2(
              title: title,
              description: description,
              onPressed1: onPressed1,
              onPressed2: onPressed2,
              buttonText1: buttonText1,
              buttonText2: buttonText2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing16),
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: DarkColor.darkest.color,
                decoration: TextDecoration.none,
              ),
            ),
          if (title != null) const SizedBox(height: spacing8),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: bSSize,
                fontWeight: bSWeight,
                color: DarkColor.light.color,
                decoration: TextDecoration.none,
              ),
            ),
          if (description != null) const SizedBox(height: spacing8),
          Spacer(),
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

  static void show({
    required BuildContext context,
    String? title,
    String? description,
    String? buttonText1,
    String? buttonText2,
    String? buttonText3,
    double width = 300,
    double height = 167,
    VoidCallback? onPressed1,
    VoidCallback? onPressed2,
    VoidCallback? onPressed3,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) => Theme(
        data: Theme.of(context),
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: AppDialog3(
              title: title,
              description: description,
              onPressed1: onPressed1,
              onPressed2: onPressed2,
              onPressed3: onPressed3,
              buttonText1: buttonText1,
              buttonText2: buttonText2,
              buttonText3: buttonText3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing16),
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: DarkColor.darkest.color,
                decoration: TextDecoration.none,
              ),
            ),
          if (title != null) const SizedBox(height: spacing8),
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: bSSize,
                fontWeight: bSWeight,
                color: DarkColor.light.color,
                decoration: TextDecoration.none,
              ),
            ),
          if (description != null) const SizedBox(height: spacing8),
          Spacer(),
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
