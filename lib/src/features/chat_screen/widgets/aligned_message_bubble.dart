import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_message_bubble.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AlignedMessageBubble extends StatelessWidget {
  final List<({Message message, String senderName})> messagesWithSenderNames;
  final int index;
  final bool isLastInSequence;
  final bool isFirstInSequence;
  final bool? isRead;
  final List<String> imageUrls;
  final String replyBody;
  final DateTime timestamp;
  final VoidCallback? onTap;
  final VoidCallback? onReplyTap;

  const AlignedMessageBubble({
    super.key,
    required this.messagesWithSenderNames,
    required this.index,
    this.isLastInSequence = false,
    this.isFirstInSequence = false,
    this.isRead,
    this.imageUrls = const [],
    this.replyBody = '',
    required this.timestamp,
    this.onTap,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = messagesWithSenderNames[index];
    final isSent = item.message.senderId ==
        (context.appState.user as AuthorizedUser).id;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: spacing4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          child: AppMessageBubble(
            name: isFirstInSequence ? item.senderName : null,
            body: item.message.body,
            imageUrls: imageUrls,
            isLastInSequence: isLastInSequence,
            isRead: isRead,
            replyBody: replyBody,
            messageType: isSent ? MessageType.sent : MessageType.received,
            timestamp: timestamp,
            onTap: onTap,
            onReplyTap: onReplyTap,
          ),
        ),
      ),
    );
  }
}
