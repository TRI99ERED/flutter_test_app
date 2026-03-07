import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
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
        child: SafeArea(
          child: FutureBuilder<String>(
            future: context.appController.getOtherName(widget.chatId),
            builder: (context, snapshot) {
              final title = snapshot.data ?? 'Unknown';
              return AppNavBar(
                title: title,
                leftIcon: AppIcons.arrowLeft,
                rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                onPressedLeft: () {
                  context.pop();
                },
                onPressedRight: () {},
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                        return ErrorState(
                          message: 'Error loading messages: ${snapshot.error}',
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const EmptyState(title: 'No messages yet');
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
                onSendPressed: (value) async {
                  final user = context.appState.user as AuthorizedUser;
                  await context.appController.createMessage(
                    chatId: widget.chatId,
                    senderId: user.id,
                    senderName: user.name,
                    body: value,
                  );

                  await context.appController.updateChatLastMessage(
                    chatId: widget.chatId,
                    lastMessage: value,
                  );

                  final chat = await context.appController
                      .watchChatsForUser(user.id)
                      .first;
                  final currentChat = chat.firstWhere(
                    (c) => c.id == widget.chatId,
                  );

                  for (final participantId in currentChat.participants) {
                    if (participantId != user.id) {
                      final unreadCount = await context.appController
                          .watchChatUnreadCount(widget.chatId)
                          .first;
                      await context.appController.updateChatUnreadCount(
                        chatId: widget.chatId,
                        unreadCount: unreadCount + 1,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
