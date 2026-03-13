import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/widgets/chat_wizard.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';
import 'package:test_app/src/widgets/user_profile.dart';

enum ChatType { direct, group }

class ChatScreen extends StatefulWidget {
  final String chatId;
  final ChatType chatType;

  const ChatScreen({super.key, required this.chatId, required this.chatType});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _lastDirectChatId;
  String? _lastGroupChatId;
  String? _userId;
  AppController? _appController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.appState.user;
      _appController = context.appController;
      if (user is AuthorizedUser) {
        _userId = user.id;
        switch (widget.chatType) {
          case ChatType.direct:
            if (_lastDirectChatId != widget.chatId) {
              _appController?.updateUserCurrentDirectChatId(
                userId: user.id,
                currentDirectChatId: widget.chatId,
              );
              _lastDirectChatId = widget.chatId;
            }
            break;
          case ChatType.group:
            if (_lastGroupChatId != widget.chatId) {
              _appController?.updateUserCurrentGroupChatId(
                userId: user.id,
                currentGroupChatId: widget.chatId,
              );
              _lastGroupChatId = widget.chatId;
            }
            break;
        }
      }
    });
  }

  Future<Widget> _buildNavBar(BuildContext context, Chat chat) async {
    final resolvedChatName = await context.appController
        .watchAllUsers()
        .first
        .then((users) {
          if (chat is DirectChat && chat.participants.length == 2) {
            final otherId = chat.participants.firstWhere(
              (id) => id != (context.appState.user as AuthorizedUser).id,
              orElse: () => '',
            );
            if (users == null) {
              return 'Unknown';
            }
            final otherUser = users.firstWhere(
              (user) => user.id == otherId,
              orElse: () => AuthorizedUser(
                id: otherId,
                name: 'Unknown',
                email: '',
                handle: '',
                avatarUrl: '',
              ),
            );
            return otherUser.name;
          } else if (chat is GroupChat) {
            return chat.name;
          }
          return 'Unknown';
        });
    if (chat is DirectChat && chat.participants.length == 2) {
      final otherId = chat.participants.firstWhere(
        (id) => id != (context.appState.user as AuthorizedUser).id,
        orElse: () => '',
      );
      if (!context.mounted) {
        return const AppNavBar(title: 'Loading...');
      }
      return StreamBuilder(
        stream: context.appController.watchUserWithId(otherId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return AppNavBar(
              title: 'Error',
              leftIcon: AppIcons.arrowLeft,
              onPressedLeft: () => context.pop(),
              rightImage: null,
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
            onPressedRight: () {
              UserProfile.show(context, otherUser, mode: UserProfileMode.view);
            },
          );
        },
      );
    }
    if (chat is GroupChat) {
      return AppNavBar(
        title: chat.name,
        leftIcon: AppIcons.arrowLeft,
        rightImage: AppAvatar.groupAvatarOrPlaceholder(chat, AvatarSize.small),
        onPressedLeft: () {
          context.pop();
        },
        onPressedRight: () {
          ChatWizard.manageChat(
            context,
            mode: ChatWizardMode.edit,
            chatToEdit: chat,
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
  }

  Widget _buildMessageList(BuildContext context, Chat chat) {
    final messageStream = chat is DirectChat
        ? context.appController.watchMessagesForDirectChat(widget.chatId)
        : context.appController.watchMessagesForGroupChat(widget.chatId);
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ErrorState(
              message: 'Failed to load messages: ${snapshot.error}',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return const Center(child: AppLoader());
        }
        final messages = snapshot.data ?? [];
        if ((snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) &&
            messages.isEmpty) {
          return const EmptyState(title: 'No messages yet');
        }
        return StreamBuilder(
          stream: context.appController.watchAllUsers(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasError) {
              return Center(
                child: ErrorState(
                  message: 'Failed to load users: ${asyncSnapshot.error}',
                ),
              );
            }
            final users = asyncSnapshot.data ?? [];
            final messagesWithSenderNames = <Message, String>{};
            for (final message in messages) {
              final sender = users.firstWhere(
                (user) => user.id == message.senderId,
                orElse: () {
                  return AuthorizedUser(
                    id: message.senderId,
                    name: 'Unknown',
                    email: '',
                    handle: '',
                    avatarUrl: '',
                  );
                },
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
                    messages[index - 1].senderId != messages[index].senderId) {
                  return AlignedMessageBubble(
                    messagesWithSenderNames: messagesWithSenderNames,
                    index: index,
                    isLastInSequence: true,
                  );
                }
                if (index == messages.length - 1 ||
                    messages[index + 1].senderId != messages[index].senderId) {
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
  }

  Widget _buildMessageInput(BuildContext context, Chat chat) {
    if (chat is DirectChat) {
      return StreamBuilder(
        stream: context.appController.watchDirectChatUnreadCount(widget.chatId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorState(
              message: 'Failed to load unread count: ${asyncSnapshot.error}',
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
              final chatList = await appController
                  .watchDirectChatsForUser(user.id)
                  .first;
              final currentChat = chatList?.firstWhere(
                (c) => c.id == widget.chatId,
              );
              final users = await appController.watchAllUsers().first;
              for (final participantId in currentChat?.participants ?? []) {
                if (participantId != user.id) {
                  final participant = users?.firstWhere(
                    (u) => u.id == participantId,
                    orElse: () => AuthorizedUser(
                      id: participantId,
                      name: 'Unknown',
                      email: '',
                      handle: '',
                      avatarUrl: '',
                    ),
                  );
                  if (participant?.currentDirectChatId != widget.chatId) {
                    await appController.updateDirectChatUnreadCount(
                      chatId: widget.chatId,
                      unreadCount: unreadCount + 1,
                    );
                  }
                }
              }
            },
          );
        },
      );
    } else if (chat is GroupChat) {
      return StreamBuilder(
        stream: context.appController.watchGroupChatUnreadCounts(widget.chatId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorState(
              message: 'Failed to load unread counts: ${asyncSnapshot.error}',
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
              final chatList = await appController
                  .watchGroupChatsForUser(user.id)
                  .first;
              final currentChat = chatList?.firstWhere(
                (c) => c.id == widget.chatId,
              );
              final users = await appController.watchAllUsers().first;
              final updatedUnreadCounts = Map<String, int>.from(unreadCounts);
              for (final participantId in currentChat?.participants ?? []) {
                if (participantId != user.id) {
                  final participant = users?.firstWhere(
                    (u) => u.id == participantId,
                    orElse: () => AuthorizedUser(
                      id: participantId,
                      name: 'Unknown',
                      email: '',
                      handle: '',
                      avatarUrl: '',
                    ),
                  );
                  if (participant?.currentGroupChatId != widget.chatId) {
                    updatedUnreadCounts[participantId] =
                        (updatedUnreadCounts[participantId] ?? 0) + 1;
                  }
                }
              }
              await appController.updateGroupChatUnreadCounts(
                chatId: widget.chatId,
                unreadCounts: updatedUnreadCounts,
              );
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Scaffold _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppNavBar(
            title: 'Chat not found',
            leftIcon: AppIcons.arrowLeft,
            onPressedLeft: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(child: ErrorState(message: 'Chat not found')),
      ),
    );
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
      child: switch (widget.chatType) {
        ChatType.direct => StreamBuilder(
          stream: context.appController.watchDirectChatWithId(widget.chatId),
          builder: (context, directSnapshot) {
            if (directSnapshot.hasError) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: AppNavBar(
                      title: 'Error',
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => context.pop(),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ErrorState(
                      message: 'Failed to load chat: ${directSnapshot.error}',
                    ),
                  ),
                ),
              );
            }
            final directLoading =
                directSnapshot.connectionState == ConnectionState.waiting ||
                directSnapshot.connectionState == ConnectionState.none;
            final directChat = directSnapshot.data;
            if (directLoading) {
              return const Scaffold(body: Center(child: AppLoader()));
            }
            if (directChat != null) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: FutureBuilder<Widget>(
                      future: _buildNavBar(context, directChat),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const AppNavBar(title: 'Loading...');
                        } else if (snapshot.hasError) {
                          return const AppNavBar(title: 'Error');
                        } else {
                          return snapshot.data!;
                        }
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
                            child: _buildMessageList(context, directChat),
                          ),
                        ),
                        _buildMessageInput(context, directChat),
                      ],
                    ),
                  ),
                ),
              );
            }
            return _buildErrorState(context);
          },
        ),
        ChatType.group => StreamBuilder(
          stream: context.appController.watchGroupChatWithId(widget.chatId),
          builder: (context, groupSnapshot) {
            if (groupSnapshot.hasError) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: AppNavBar(
                      title: 'Error',
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => context.pop(),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ErrorState(
                      message: 'Failed to load chat: ${groupSnapshot.error}',
                    ),
                  ),
                ),
              );
            }
            final groupLoading =
                groupSnapshot.connectionState == ConnectionState.waiting ||
                groupSnapshot.connectionState == ConnectionState.none;
            final groupChat = groupSnapshot.data;
            if (groupLoading) {
              return const Scaffold(body: Center(child: AppLoader()));
            }
            if (groupChat != null) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: FutureBuilder<Widget>(
                      future: _buildNavBar(context, groupChat),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const AppNavBar(title: 'Loading...');
                        } else if (snapshot.hasError) {
                          return const AppNavBar(title: 'Error');
                        } else {
                          return snapshot.data!;
                        }
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
                            child: _buildMessageList(context, groupChat),
                          ),
                        ),
                        _buildMessageInput(context, groupChat),
                      ],
                    ),
                  ),
                ),
              );
            }
            return _buildErrorState(context);
          },
        ),
      },
    );
  }

  @override
  void dispose() {
    switch (widget.chatType) {
      case ChatType.direct:
        if (_userId != null &&
            _appController != null &&
            _lastDirectChatId != null) {
          _appController!.updateUserCurrentDirectChatId(
            userId: _userId!,
            currentDirectChatId: '',
          );
        }
        break;
      case ChatType.group:
        if (_userId != null &&
            _appController != null &&
            _lastGroupChatId != null) {
          _appController!.updateUserCurrentGroupChatId(
            userId: _userId!,
            currentGroupChatId: '',
          );
        }
        break;
    }
    super.dispose();
  }
}
