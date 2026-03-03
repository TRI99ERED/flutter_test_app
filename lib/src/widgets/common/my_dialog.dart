import 'package:flutter/widgets.dart';
import 'package:test_app/src/widgets/common/my_button.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyDialog2 extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final String? buttonText1;
  final String? buttonText2;

  const MyDialog2({
    super.key,
    this.title,
    this.description,
    this.onPressed1,
    this.onPressed2,
    this.buttonText1,
    this.buttonText2,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 167),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(fontSize: h3Size, fontWeight: h3Weight),
              ),
            if (title != null) const SizedBox(height: 8),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(fontSize: bSSize, fontWeight: bSWeight),
              ),
            if (description != null) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButtonSecondary(onPressed: onPressed1, text: buttonText1),
                const SizedBox(width: 8),
                MyButtonPrimary(onPressed: onPressed2, text: buttonText2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyDialog3 extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final VoidCallback? onPressed3;
  final String? buttonText1;
  final String? buttonText2;
  final String? buttonText3;

  const MyDialog3({
    super.key,
    this.title,
    this.description,
    this.onPressed1,
    this.onPressed2,
    this.onPressed3,
    this.buttonText1,
    this.buttonText2,
    this.buttonText3,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 259),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(fontSize: h3Size, fontWeight: h3Weight),
              ),
            if (title != null) const SizedBox(height: 8),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(fontSize: bSSize, fontWeight: bSWeight),
              ),
            const SizedBox(height: 8),
            MyButtonSecondary(onPressed: onPressed1, text: buttonText1),
            const SizedBox(height: 8),
            MyButtonSecondary(onPressed: onPressed2, text: buttonText2),
            const SizedBox(height: 8),
            MyButtonPrimary(onPressed: onPressed3, text: buttonText3),
          ],
        ),
      ),
    );
  }
}
