import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyActionSheet extends StatelessWidget {
  final int actionCount;
  final List<String> actionTitles;
  final List<IconData?>? actionIcons;
  final List<VoidCallback> onActionPressed;

  const MyActionSheet({
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
        return MyAction(
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

class MyAction extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const MyAction({super.key, required this.text, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: DarkColor.light.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 20),
          if (icon != null) const SizedBox(width: 12),
          if (icon == null) const SizedBox(width: 32),
          Text(text),
        ],
      ),
    );
  }
}
