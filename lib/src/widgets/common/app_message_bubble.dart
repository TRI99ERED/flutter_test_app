import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum MessageType { received, sent }

class AppMessageBubble extends StatelessWidget {
  final String? name;
  final String body;
  final bool isLastInSequence;
  final MessageType messageType;

  const AppMessageBubble({
    super.key,
    this.name,
    required this.body,
    required this.isLastInSequence,
    required this.messageType,
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
      MessageType.received => Container(
        padding: const EdgeInsets.symmetric(
          vertical: spacing12,
          horizontal: spacing16,
        ),
        decoration: BoxDecoration(
          color: LightColor.light.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isLastInSequence
                ? Radius.zero
                : const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
        ),
        child: _buildMessageContent(
          DarkColor.dark.color,
          DarkColor.darkest.color,
        ),
      ),
      MessageType.sent => Container(
        padding: const EdgeInsets.symmetric(
          vertical: spacing12,
          horizontal: spacing16,
        ),
        decoration: BoxDecoration(
          color: HighlightColor.darkest.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: const Radius.circular(20),
            bottomRight: isLastInSequence
                ? Radius.zero
                : const Radius.circular(20),
          ),
        ),
        child: _buildMessageContent(
          HighlightColor.light.color,
          LightColor.lightest.color,
        ),
      ),
    };
  }
}
