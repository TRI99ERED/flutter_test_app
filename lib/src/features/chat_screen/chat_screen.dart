import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
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
  Future<String>? _chatNameFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _chatNameFuture = _resolveChatName();
      _initialized = true;
    }
  }

  Future<String> _resolveChatName() async {
    final chat = await context.appController
        .watchChatWithId(widget.chatId)
        .first;
    final title = chat.name;

    if (title.isEmpty) {
      final otherUserId = chat.participants.firstWhere(
        (id) => id != (context.appState.user as AuthorizedUser).id,
      );
      if (!context.mounted) return 'Unknown';
      final user = await context.appController.getUserWithId(otherUserId);
      return user.name;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SafeArea(
            child: FutureBuilder<String>(
              future: _chatNameFuture,
              builder: (context, snapshot) {
                final resolvedChatName = snapshot.data ?? 'Loading...';
                return StreamBuilder(
                  stream: context.appController.watchChatWithId(widget.chatId),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return AppNavBar(
                        title: 'Loading...',
                        leftIcon: AppIcons.arrowLeft,
                        onPressedLeft: () {
                          context.pop();
                        },
                      );
                    } else if (asyncSnapshot.hasError) {
                      return AppNavBar(
                        title: 'Error',
                        leftIcon: AppIcons.arrowLeft,
                        onPressedLeft: () {
                          context.pop();
                        },
                      );
                    }

                    final chat = asyncSnapshot.data;

                    if (chat == null) {
                      return AppNavBar(
                        title: 'Chat not found',
                        leftIcon: AppIcons.arrowLeft,
                        onPressedLeft: () {
                          context.pop();
                        },
                      );
                    }
                    if (chat.participants.length == 2) {
                      final otherId = chat.participants.firstWhere(
                        (id) =>
                            id != (context.appState.user as AuthorizedUser).id,
                      );

                      return StreamBuilder(
                        stream: context.appController.watchUserWithId(otherId),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return AppNavBar(
                              title: 'Loading...',
                              leftIcon: AppIcons.arrowLeft,
                              onPressedLeft: () {
                                context.pop();
                              },
                            );
                          } else if (asyncSnapshot.hasError) {
                            return AppNavBar(
                              title: 'Error',
                              leftIcon: AppIcons.arrowLeft,
                              onPressedLeft: () {
                                context.pop();
                              },
                            );
                          }

                          final otherUser = asyncSnapshot.data;

                          if (otherUser == null) {
                            return AppNavBar(
                              title: 'User not found',
                              leftIcon: AppIcons.arrowLeft,
                              onPressedLeft: () {
                                context.pop();
                              },
                            );
                          }

                          return AppNavBar(
                            title: resolvedChatName,
                            leftIcon: AppIcons.arrowLeft,
                            rightImage: AppAvatar.avatarOrPlaceholder(
                              otherUser,
                              AvatarSize.small,
                            ),
                            onPressedLeft: () {
                              context.pop();
                            },
                            onPressedRight: () {},
                          );
                        },
                      );
                    }
                    return AppNavBar(
                      title: resolvedChatName,
                      leftIcon: AppIcons.arrowLeft,
                      rightImage: const PlaceholderAvatar(
                        size: AvatarSize.small,
                      ),
                      onPressedLeft: () {
                        context.pop();
                      },
                      onPressedRight: () {},
                    );
                  },
                );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(spacing8),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(width: 32, child: AppLoader()),
                          );
                        } else if (snapshot.hasError) {
                          return ErrorState(
                            message:
                                'Error loading messages: ${snapshot.error}',
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
                StreamBuilder(
                  stream: context.appController.watchChatUnreadCount(
                    widget.chatId,
                  ),
                  builder: (context, asyncSnapshot) {
                    final unreadCount = asyncSnapshot.data ?? 0;

                    return AppMessageInput(
                      onSendPressed: (value) async {
                        final user = context.appState.user as AuthorizedUser;
                        final appController = context.appController;

                        await appController.createMessage(
                          chatId: widget.chatId,
                          senderId: user.id,
                          senderName: user.name,
                          body: value,
                        );

                        await appController.updateChatLastMessage(
                          chatId: widget.chatId,
                          lastMessage: value,
                        );

                        final chat = await appController
                            .watchChatsForUser(user.id)
                            .first;
                        final currentChat = chat.firstWhere(
                          (c) => c.id == widget.chatId,
                        );

                        for (final participantId in currentChat.participants) {
                          if (participantId != user.id) {
                            await appController.updateChatUnreadCount(
                              chatId: widget.chatId,
                              unreadCount: unreadCount + 1,
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
