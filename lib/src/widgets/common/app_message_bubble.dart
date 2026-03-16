import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum MessageType { received, sent }

class AppMessageBubble extends StatelessWidget {
  final String? name;
  final String body;
  final bool isLastInSequence;
  final MessageType messageType;
  final VoidCallback? onTap;

  const AppMessageBubble({
    super.key,
    this.name,
    required this.body,
    required this.isLastInSequence,
    required this.messageType,
    this.onTap,
  });

  Widget _buildMessageContent(Color nameColor, Color bodyColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (messageType) {
      MessageType.received => TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: spacing12,
            horizontal: spacing16,
          ),
          backgroundColor: LightColor.light.color,
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
          DarkColor.dark.color,
          DarkColor.darkest.color,
        ),
      ),
      MessageType.sent => TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: spacing12,
            horizontal: spacing16,
          ),
          backgroundColor: HighlightColor.darkest.color,
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
          HighlightColor.light.color,
          LightColor.lightest.color,
        ),
      ),
    };
  }
}
