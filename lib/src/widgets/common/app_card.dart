import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_tag.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppCardLarge extends StatelessWidget {
  final Widget? image;
  final IconData? icon;
  final Widget? avatar;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? tagText;
  final String? buttonText;
  final VoidCallback? onIconButtonPressed;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onTagPressed;
  final VoidCallback? onPressed;

  const AppCardLarge({
    super.key,
    this.image,
    this.icon,
    this.avatar,
    this.title,
    this.subtitle,
    this.description,
    this.tagText,
    this.buttonText,
    this.onIconButtonPressed,
    this.onAvatarPressed,
    this.onTagPressed,
    this.onPressed,
  }) : assert(
         (icon != null && onIconButtonPressed != null) ||
             (icon == null && onIconButtonPressed == null),
         'icon and onIconButtonPressed must both be provided or both be null',
       ),
       assert(
         (tagText != null && onTagPressed != null) ||
             (tagText == null && onTagPressed == null),
         'tagText and onTagPressed must both be provided or both be null',
       ),
       assert(
         icon == null || avatar == null,
         'icon and avatar cannot both be provided',
       ),
       assert(
         (buttonText != null && onPressed != null) ||
             (buttonText == null && onPressed == null),
         'buttonText and onPressed must both be provided or both be null',
       );

  Widget _buildTopActionsRow() {
    return Row(
      children: [
        if (icon != null)
          IconButton(
            onPressed: onIconButtonPressed,
            icon: Icon(icon),
            style: IconButton.styleFrom(
              backgroundColor: LightColor.medium.color,
              foregroundColor: HighlightColor.darkest.color,
            ),
          ),
        if (avatar != null)
          IconButton(icon: avatar!, onPressed: onAvatarPressed),
        const Spacer(),
        if (tagText != null) AppTag(text: tagText, onPressed: onTagPressed),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTopActions = icon != null || tagText != null || avatar != null;

    return Container(
      decoration: BoxDecoration(
        color: LightColor.light.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: image,
                  ),
                  if (hasTopActions)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: _buildTopActionsRow(),
                    ),
                ],
              ),
            )
          else if (hasTopActions)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: _buildTopActionsRow(),
            ),
          if (title != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: h4Size,
                  fontWeight: h4Weight,
                  color: DarkColor.darkest.color,
                ),
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing8),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: bSSize,
                  fontWeight: bSWeight,
                  color: DarkColor.light.color,
                ),
              ),
            ),
          if (description != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: Text(
                description!,
                softWrap: true,
                style: TextStyle(
                  fontSize: bSSize,
                  fontWeight: bSWeight,
                  color: DarkColor.medium.color,
                ),
              ),
            ),
          if (onPressed != null && buttonText != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: SizedBox(
                width: double.infinity,
                child: AppButtonSecondary(
                  text: buttonText,
                  onPressed: onPressed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppCardSmall extends StatelessWidget {
  final Widget? image;
  final Widget? avatar;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onIconButtonPressed;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onPressed;

  const AppCardSmall({
    super.key,
    this.image,
    this.avatar,
    this.icon,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onIconButtonPressed,
    this.onAvatarPressed,
    this.onPressed,
  }) : assert(
         (icon != null && onIconButtonPressed != null) ||
             (icon == null && onIconButtonPressed == null),
         'icon and onIconButtonPressed must both be provided or both be null',
       ),
       assert(
         (avatar != null && onAvatarPressed != null) ||
             (avatar == null && onAvatarPressed == null),
         'avatar and onAvatarPressed must both be provided or both be null',
       ),
       assert(
         (icon == null && avatar == null && image == null) ||
             (icon != null && avatar == null && image == null) ||
             (icon == null && avatar != null && image == null) ||
             (icon == null && avatar == null && image != null),
         'At most one of icon, avatar, or image can be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.light.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (image != null)
            SizedBox(
              width: 80,
              height: 72,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: image,
              ),
            ),
          if (avatar != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: IconButton(icon: avatar!, onPressed: onAvatarPressed),
            ),
          if (icon != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: IconButton(
                icon: Icon(icon),
                onPressed: onIconButtonPressed,
                style: IconButton.styleFrom(
                  backgroundColor: LightColor.medium.color,
                  foregroundColor: HighlightColor.darkest.color,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(spacing8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: h4Size,
                        fontWeight: h4Weight,
                        color: DarkColor.darkest.color,
                      ),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: bSSize,
                        fontWeight: bSWeight,
                        color: DarkColor.light.color,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (onPressed != null && buttonText != null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: AppButtonSecondary(text: buttonText, onPressed: onPressed),
            ),
          if (onPressed != null && buttonText == null)
            Padding(
              padding: EdgeInsets.all(spacing8),
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(
                  AppIcons.arrowRight,
                  size: 12,
                  color: DarkColor.lightest.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
