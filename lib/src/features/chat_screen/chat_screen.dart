import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
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

enum ChatType { direct, group }

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Widget _buildNavBar(BuildContext context, Stream<ChatType> chatTypeStream) {
    return StreamBuilder(
      stream: chatTypeStream,
      builder: (context, snapshot) {
        final chatType = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppNavBar(
            title: 'Loading...',
            leftIcon: AppIcons.arrowLeft,
            onPressedLeft: () {
              context.pop();
            },
          );
        } else if (snapshot.hasError || chatType == null) {
          return AppNavBar(
            title: 'Error',
            leftIcon: AppIcons.arrowLeft,
            onPressedLeft: () {
              context.pop();
            },
          );
        }
        if (chatType == ChatType.direct) {
          return StreamBuilder(
            stream: context.appController.watchDirectChatWithId(widget.chatId),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
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
              final resolvedChatName =
                  chat?.name
                      .split((context.appState.user as AuthorizedUser).name)
                      .join()
                      .split(', ')
                      .join() ??
                  'Unknown';
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
                  (id) => id != (context.appState.user as AuthorizedUser).id,
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
                rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                onPressedLeft: () {
                  context.pop();
                },
                onPressedRight: () {},
              );
            },
          );
        } else {
          return StreamBuilder(
            stream: context.appController.watchGroupChatWithId(widget.chatId),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
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
              final resolvedChatName = asyncSnapshot.data?.name ?? 'Unknown';
              return AppNavBar(
                title: resolvedChatName,
                leftIcon: AppIcons.arrowLeft,
                rightImage: AppAvatar.groupAvatarOrPlaceholder(
                  asyncSnapshot.data,
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
      },
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    Stream<ChatType> chatTypeStream,
  ) {
    return StreamBuilder(
      stream: chatTypeStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 32, child: AppLoader()));
        } else if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
          return ErrorState(
            message: 'Error loading chat: ${asyncSnapshot.error}',
          );
        }
        if (asyncSnapshot.data == null) {
          return const ErrorState(message: 'Chat not found');
        }
        final chatType = asyncSnapshot.data!;
        final messageStream = chatType == ChatType.direct
            ? context.appController.watchMessagesForDirectChat(widget.chatId)
            : context.appController.watchMessagesForGroupChat(widget.chatId);
        return StreamBuilder(
          stream: messageStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(width: 32, child: AppLoader()),
              );
            }
            if (snapshot.hasError) {
              return ErrorState(
                message: 'Error loading messages: ${snapshot.error}',
              );
            }
            final messages = snapshot.data ?? [];
            if (messages.isEmpty) {
              return const EmptyState(title: 'No messages yet');
            }
            return StreamBuilder(
              stream: context.appController.watchAllUsers(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(width: 32, child: AppLoader()),
                  );
                } else if (asyncSnapshot.hasError) {
                  return ErrorState(
                    message: 'Error loading messages: ${asyncSnapshot.error}',
                  );
                }
                final users = asyncSnapshot.data ?? [];
                final messagesWithSenderNames = <Message, String>{};
                for (final message in messages) {
                  final sender = users.firstWhere(
                    (user) => user.id == message.senderId,
                  );
                  messagesWithSenderNames[message] = sender.name;
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
                        messagesWithSenderNames: messagesWithSenderNames,
                        index: index,
                        isFirstInSequence: true,
                        isLastInSequence: true,
                      );
                    }
                    if (index == 0 ||
                        messages[index - 1].senderId !=
                            messages[index].senderId) {
                      return AlignedMessageBubble(
                        messagesWithSenderNames: messagesWithSenderNames,
                        index: index,
                        isLastInSequence: true,
                      );
                    }
                    if (index == messages.length - 1 ||
                        messages[index + 1].senderId !=
                            messages[index].senderId) {
                      return AlignedMessageBubble(
                        messagesWithSenderNames: messagesWithSenderNames,
                        index: index,
                        isFirstInSequence: true,
                      );
                    }
                    return AlignedMessageBubble(
                      messagesWithSenderNames: messagesWithSenderNames,
                      index: index,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    Stream<ChatType> chatTypeStream,
  ) {
    return StreamBuilder(
      stream: chatTypeStream,
      builder: (context, asyncSnapshot) {
        final chatType = asyncSnapshot.data;
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader();
        } else if (asyncSnapshot.hasError || chatType == null) {
          return ErrorState(
            message: 'Error loading chat: ${asyncSnapshot.error}',
          );
        }
        if (chatType == ChatType.direct) {
          return StreamBuilder(
            stream: context.appController.watchDirectChatUnreadCount(
              widget.chatId,
            ),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const AppLoader();
              } else if (asyncSnapshot.hasError) {
                return ErrorState(
                  message: 'Error loading chat: ${asyncSnapshot.error}',
                );
              }
              final unreadCount = asyncSnapshot.data ?? 0;
              return AppMessageInput(
                onSendPressed: (value) async {
                  final user = context.appState.user as AuthorizedUser;
                  final appController = context.appController;
                  await appController.createDirectChatMessage(
                    chatId: widget.chatId,
                    senderId: user.id,
                    senderName: user.name,
                    body: value,
                  );
                  await appController.updateDirectChatLastMessage(
                    chatId: widget.chatId,
                    lastMessage: value,
                  );
                  final chat = await appController
                      .watchDirectChatsForUser(user.id)
                      .first;
                  final currentChat = chat.firstWhere(
                    (c) => c.id == widget.chatId,
                  );
                  for (final participantId in currentChat.participants) {
                    if (participantId != user.id) {
                      await appController.updateDirectChatUnreadCount(
                        chatId: widget.chatId,
                        unreadCount: unreadCount + 1,
                      );
                    }
                  }
                },
              );
            },
          );
        } else {
          return StreamBuilder(
            stream: context.appController.watchGroupChatUnreadCounts(
              widget.chatId,
            ),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const AppLoader();
              } else if (asyncSnapshot.hasError) {
                return ErrorState(
                  message: 'Error loading chat: ${asyncSnapshot.error}',
                );
              }
              final unreadCounts = asyncSnapshot.data ?? {};
              return AppMessageInput(
                onSendPressed: (value) async {
                  final user = context.appState.user as AuthorizedUser;
                  final appController = context.appController;
                  await appController.createGroupChatMessage(
                    chatId: widget.chatId,
                    senderId: user.id,
                    senderName: user.name,
                    body: value,
                  );
                  await appController.updateGroupChatLastMessage(
                    chatId: widget.chatId,
                    lastMessage: value,
                  );
                  final chat = await appController
                      .watchGroupChatsForUser(user.id)
                      .first;
                  final currentChat = chat.firstWhere(
                    (c) => c.id == widget.chatId,
                  );
                  for (final participantId in currentChat.participants) {
                    if (participantId != user.id) {
                      await appController.updateGroupChatUnreadCounts(
                        chatId: widget.chatId,
                        unreadCounts: unreadCounts.map(
                          (key, value) => MapEntry(
                            key,
                            key == participantId ? value + 1 : value,
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTypeStream = context.appController
        .watchChatWithId(widget.chatId)
        .map((chat) {
          return chat is DirectChat ? ChatType.direct : ChatType.group;
        })
        .asBroadcastStream();

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
          child: SafeArea(child: _buildNavBar(context, chatTypeStream)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(spacing8),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(spacing8),
                    child: _buildMessageList(context, chatTypeStream),
                  ),
                ),
                _buildMessageInput(context, chatTypeStream),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
