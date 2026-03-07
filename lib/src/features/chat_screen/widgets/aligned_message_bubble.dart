import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_message_bubble.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AlignedMessageBubble extends StatelessWidget {
  final List<Message> messages;
  final int index;
  final bool isLastInSequence;
  final bool isFirstInSequence;

  const AlignedMessageBubble({
    super.key,
    required this.messages,
    required this.index,
    this.isLastInSequence = false,
    this.isFirstInSequence = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          messages[index].senderId ==
              (context.appState.user as AuthorizedUser).id
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: spacing4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          child: AppMessageBubble(
            name: isFirstInSequence ? messages[index].senderName : null,
            body: messages[index].body,
            isLastInSequence: isLastInSequence,
            messageType:
                messages[index].senderId ==
                    (context.appState.user as AuthorizedUser).id
                ? MessageType.sent
                : MessageType.received,
          ),
        ),
      ),
    );
  }
}
