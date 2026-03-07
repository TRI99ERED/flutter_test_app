import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder<String>(
          future: context.appController.getOtherName(widget.chatId),
          builder: (context, snapshot) {
            final title = snapshot.data ?? 'Unknown';
            return AppNavBar(title: title);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: spacing8,
          vertical: spacing8,
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(spacing8),
                child: StreamBuilder(
                  stream: context.appController.watchMessagesForChat(
                    widget.chatId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(width: 32, child: AppLoader()),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error loading messages: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: h1Size,
                          fontWeight: h1Weight,
                          color: ErrorColor.dark.color,
                        ),
                      );
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: h1Size,
                            fontWeight: h1Weight,
                            color: DarkColor.darkest.color,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        if ((index == 0 ||
                                messages[index - 1].senderId !=
                                    messages[index].senderId) &&
                            (index == messages.length - 1 ||
                                messages[index + 1].senderId !=
                                    messages[index].senderId)) {
                          return AlignedMessageBubble(
                            messages: messages,
                            index: index,
                            isFirstInSequence: true,
                            isLastInSequence: true,
                          );
                        }

                        if (index == 0 ||
                            messages[index - 1].senderId !=
                                messages[index].senderId) {
                          return AlignedMessageBubble(
                            messages: messages,
                            index: index,
                            isLastInSequence: true,
                          );
                        }

                        if (index == messages.length - 1 ||
                            messages[index + 1].senderId !=
                                messages[index].senderId) {
                          return AlignedMessageBubble(
                            messages: messages,
                            index: index,
                            isFirstInSequence: true,
                          );
                        }

                        return AlignedMessageBubble(
                          messages: messages,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            AppMessageInput(
              onMorePressed: () {},
              onSendPressed: (value) {
                context.appController.createMessage(
                  chatId: widget.chatId,
                  senderId: (context.appState.user as AuthorizedUser).id,
                  senderName: (context.appState.user as AuthorizedUser).name,
                  body: value,
                );

                context.appController.updateChatLastMessage(
                  chatId: widget.chatId,
                  lastMessage: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
