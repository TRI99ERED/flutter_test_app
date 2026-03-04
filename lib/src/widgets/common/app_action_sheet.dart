import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppActionSheet extends StatelessWidget {
  final int actionCount;
  final List<String> actionTitles;
  final List<IconData?>? actionIcons;
  final List<VoidCallback> onActionPressed;

  const AppActionSheet({
    super.key,
    required this.actionCount,
    required this.actionTitles,
    required this.onActionPressed,
    this.actionIcons,
  }) : assert(actionCount > 0, 'actionCount must be greater than 0'),
       assert(
         actionTitles.length >= actionCount,
         'actionTitles length must be at least actionCount',
       ),
       assert(
         onActionPressed.length >= actionCount,
         'onActionPressed length must be at least actionCount',
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(actionCount, (index) {
        return AppAction(
          text: actionTitles[index],
          icon: actionIcons != null && actionIcons!.length > index
              ? actionIcons![index]
              : null,
          onPressed: () {
            if (onActionPressed.length > index) {
              onActionPressed[index]();
            }
          },
        );
      }),
    );
  }
}

class AppAction extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AppAction({super.key, required this.text, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: DarkColor.light.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 20),
          if (icon != null) SizedBox(width: spacing12),
          if (icon == null) SizedBox(width: spacing32),
          Text(text),
        ],
      ),
    );
  }
}
