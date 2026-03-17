import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_message_bubble.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AlignedMessageBubble extends StatelessWidget {
  final Map<Message, String> messagesWithSenderNames;
  final int index;
  final bool isLastInSequence;
  final bool isFirstInSequence;
  final VoidCallback? onTap;

  const AlignedMessageBubble({
    super.key,
    required this.messagesWithSenderNames,
    required this.index,
    this.isLastInSequence = false,
    this.isFirstInSequence = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          messagesWithSenderNames.keys.elementAt(index).senderId ==
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
            name: isFirstInSequence
                ? messagesWithSenderNames.values.elementAt(index)
                : null,
            body: messagesWithSenderNames.keys.elementAt(index).body,
            isLastInSequence: isLastInSequence,
            messageType:
                messagesWithSenderNames.keys.elementAt(index).senderId ==
                    (context.appState.user as AuthorizedUser).id
                ? MessageType.sent
                : MessageType.received,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
