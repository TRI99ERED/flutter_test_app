import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

enum MessageType { received, sent }

class AppMessageBubble extends StatelessWidget {
  final String? name;
  final String body;
  final bool isLastInSequence;
  final bool? isRead;
  final MessageType messageType;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const AppMessageBubble({
    super.key,
    this.name,
    required this.body,
    required this.isLastInSequence,
    required this.messageType,
    required this.isRead,
    required this.timestamp,
    this.onTap,
  });

  Widget _buildMessageContent(
    BuildContext context,
    Color? nameColor,
    Color? bodyColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (name != null)
          Text(
            name!,
            style: TextStyle(
              fontSize: h5Size,
              fontWeight: h5Weight,
              color: nameColor,
            ),
          ),
        Text(
          body,
          style: TextStyle(
            fontSize: bMSize,
            fontWeight: bMWeight,
            color: bodyColor,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeOfDay.fromDateTime(timestamp).format(context),
                style: TextStyle(
                  fontSize: cMSize,
                  fontWeight: cMWeight,
                  color: nameColor,
                ),
              ),
              if (isRead != null)
                isRead!
                    ? Icon(Icons.done_all, size: 16, color: nameColor)
                    : Icon(Icons.done, size: 16, color: nameColor),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (messageType) {
      MessageType.received => IntrinsicWidth(
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: spacing12,
              horizontal: spacing16,
            ),
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isLastInSequence
                    ? Radius.zero
                    : const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
            ),
          ),
          onPressed: onTap,
          child: _buildMessageContent(
            context,
            Theme.of(context).extension<AppTheme>()?.foregroundStrongColor,
            Theme.of(context).extension<AppTheme>()?.foregroundStrongestColor,
          ),
        ),
      ),
      MessageType.sent => IntrinsicWidth(
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: spacing12,
              horizontal: spacing16,
            ),
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkestColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: isLastInSequence
                    ? Radius.zero
                    : const Radius.circular(20),
              ),
            ),
          ),
          onPressed: onTap,
          child: _buildMessageContent(
            context,
            Theme.of(context).extension<AppTheme>()?.highlightLightColor,
            Theme.of(context).extension<AppTheme>()?.backgroundStrongestColor,
          ),
        ),
      ),
    };
  }
}
