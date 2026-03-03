import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyNavBar extends StatelessWidget {
  final String title;
  final String? leftText;
  final IconData? leftIcon;
  final Widget? leftImage;
  final String? rightText;
  final IconData? rightIcon;
  final Widget? rightImage;
  final VoidCallback? onPressedLeft;
  final VoidCallback? onPressedRight;

  const MyNavBar({
    super.key,
    required this.title,
    required this.onPressedLeft,
    required this.onPressedRight,
    this.leftText,
    this.leftIcon,
    this.rightText,
    this.rightIcon,
    this.leftImage,
    this.rightImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: (leftText != null || leftIcon != null || leftImage != null)
                ? _MyControl(
                    text: leftText,
                    icon: leftIcon,
                    image: leftImage,
                    onPressed: onPressedLeft,
                  )
                : SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: h4Size,
                fontWeight: h4Weight,
                color: DarkColor.darkest.color,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                (rightText != null || rightIcon != null || rightImage != null)
                ? _MyControl(
                    text: rightText,
                    icon: rightIcon,
                    image: rightImage,
                    onPressed: onPressedRight,
                  )
                : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _MyControl extends StatelessWidget {
  final String? _text;
  final IconData? _icon;
  final Widget? _image;
  final VoidCallback? _onPressed;

  const _MyControl({
    String? text,
    IconData? icon,
    Widget? image,
    required VoidCallback? onPressed,
  }) : _onPressed = onPressed,
       _icon = icon,
       _text = text,
       _image = image,
       assert(
         text != null || icon != null || image != null,
         'Either text, icon, or image must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _onPressed,
      style: IconButton.styleFrom(
        foregroundColor: HighlightColor.darkest.color,
      ),
      icon: _text != null
          ? Text(
              _text,
              style: TextStyle(
                color: HighlightColor.darkest.color,
                fontSize: aMSize,
                fontWeight: aMWeight,
              ),
            )
          : _image ?? Icon(_icon ?? AppIcons.arrowLeft),
    );
  }
}
