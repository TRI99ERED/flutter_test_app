import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/chat_wizard.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/features/themes/styles.dart';
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
    final l10n = context.l10n;
    final appController = context.appController;
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
              return l10n.unknownChatterLabel;
            }
            final otherUser = users.firstWhere(
              (user) => user.id == otherId,
              orElse: () => AuthorizedUser(
                id: otherId,
                name: l10n.unknownChatterLabel,
                email: '',
                handle: '',
                avatarUrl: '',
              ),
            );
            return otherUser.name;
          } else if (chat is GroupChat) {
            return chat.name;
          }
          return l10n.unknownChattersLabel;
        });
    if (chat is DirectChat && chat.participants.length == 2) {
      final otherId = chat.participants.firstWhere(
        (id) => id != (context.appState.user as AuthorizedUser).id,
        orElse: () => '',
      );
      return StreamBuilder(
        stream: appController.watchUserWithId(otherId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return AppNavBar(
              title: l10n.errorLabel,
              leftIcon: AppIcons.arrowLeft,
              onPressedLeft: () => context.pop(),
              rightImage: null,
            );
          }
          final otherUser = asyncSnapshot.data;
          if (otherUser == null) {
            return AppNavBar(
              title: l10n.userNotFoundLabel,
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
    if (chat is GroupChat && chat.participants.length > 2) {
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

  Widget _buildMessageInput(BuildContext context, Chat chat) {
    if (chat is DirectChat) {
      return StreamBuilder(
        stream: context.appController.watchDirectChatUnreadCount(widget.chatId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorState(
              message:
                  '${context.l10n.failedToLoadUnreadCountMessage}: ${asyncSnapshot.error}',
            );
          }
          final unreadCount = asyncSnapshot.data ?? 0;
          return AppMessageInput(
            onSendPressed: (value) async {
              if (value.trim().isEmpty) {
                return;
              }
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
                      name: context.l10n.unknownChatterLabel,
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
              message:
                  '${context.l10n.failedToLoadUnreadCountsMessage}: ${asyncSnapshot.error}',
            );
          }
          final unreadCounts = asyncSnapshot.data ?? {};
          return AppMessageInput(
            onSendPressed: (value) async {
              if (value.trim().isEmpty) {
                return;
              }
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
                      name: context.l10n.unknownChattersLabel,
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

  Widget _buildMessageList(BuildContext context, Chat chat) {
    final messageStream = chat is DirectChat
        ? context.appController.watchMessagesForDirectChat(widget.chatId)
        : context.appController.watchMessagesForGroupChat(widget.chatId);
    final usersStream = context.appController.watchAllUsers();
    return StreamBuilder(
      stream: StreamZip([messageStream, usersStream]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ErrorState(
              message:
                  '${context.l10n.failedToLoadChatDataMessage}: ${snapshot.error}',
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: AppLoader());
        }
        final messages = (snapshot.data?[0] ?? []) as List<Message>;
        final users = (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
        if (messages.isEmpty) {
          return EmptyState(title: context.l10n.noMessagesYetLabel);
        }
        final messagesWithSenderNames = <Message, String>{};
        for (final message in messages) {
          final sender = users.firstWhere(
            (user) => user.id == message.senderId,
            orElse: () {
              return AuthorizedUser(
                id: message.senderId,
                name: context.l10n.unknownChatterLabel,
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
            final message = messages[index];
            bool? isRead;
            if (message.senderId ==
                (context.appState.user as AuthorizedUser).id) {
              if (chat is DirectChat) {
                final sentMessages = messages
                    .where(
                      (m) =>
                          m.senderId ==
                          (context.appState.user as AuthorizedUser).id,
                    )
                    .toList();
                final sentIndex = sentMessages.indexOf(message);
                isRead = sentIndex >= chat.unreadCount;
              } else if (chat is GroupChat) {
                final sentMessages = messages
                    .where(
                      (m) =>
                          m.senderId ==
                          (context.appState.user as AuthorizedUser).id,
                    )
                    .toList();
                final sentIndex = sentMessages.indexOf(message);
                final unreadCountsExcludingThisUser = chat.unreadCounts
                  ..remove((context.appState.user as AuthorizedUser).id);
                final lowestUnreadCount =
                    unreadCountsExcludingThisUser.values.isEmpty
                    ? 0
                    : unreadCountsExcludingThisUser.values.reduce(
                        (a, b) => a < b ? a : b,
                      );
                isRead = sentIndex >= lowestUnreadCount;
              }
            }

            if ((index == 0 ||
                    messages[index - 1].senderId != messages[index].senderId) &&
                (index == messages.length - 1 ||
                    messages[index + 1].senderId != messages[index].senderId)) {
              return AlignedMessageBubble(
                messagesWithSenderNames: messagesWithSenderNames,
                index: index,
                isFirstInSequence: true,
                isLastInSequence: true,
                isRead: isRead,
                timestamp: messages[index].timestamp,
                onTap: () {
                  _handleMessageTap(context, messages[index]);
                },
              );
            }
            if (index == 0 ||
                messages[index - 1].senderId != messages[index].senderId) {
              return AlignedMessageBubble(
                messagesWithSenderNames: messagesWithSenderNames,
                index: index,
                isLastInSequence: true,
                isRead: isRead,
                timestamp: messages[index].timestamp,
                onTap: () {
                  _handleMessageTap(context, messages[index]);
                },
              );
            }
            if (index == messages.length - 1 ||
                messages[index + 1].senderId != messages[index].senderId) {
              return AlignedMessageBubble(
                messagesWithSenderNames: messagesWithSenderNames,
                index: index,
                isFirstInSequence: true,
                isRead: isRead,
                timestamp: messages[index].timestamp,
                onTap: () {
                  _handleMessageTap(context, messages[index]);
                },
              );
            }
            return AlignedMessageBubble(
              messagesWithSenderNames: messagesWithSenderNames,
              index: index,
              isRead: isRead,
              timestamp: messages[index].timestamp,
              onTap: () {
                _handleMessageTap(context, messages[index]);
              },
            );
          },
        );
      },
    );
  }

  void _handleMessageTap(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).extension<AppTheme>()?.backgroundStrongestColor,
      elevation: 0,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.3,
      ),
      barrierColor: Colors.black.withAlpha(216),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      showDragHandle: true,
      builder: (context) {
        return Column(
          spacing: spacing8,
          children: [
            AppListItem(
              title: context.l10n.saveMessageLabel,
              onPressed: () async {
                await context.appController.saveMessage(
                  SavedMessage(
                    id: message.id,
                    senderId: message.senderId,
                    body: message.body,
                    timestamp: message.timestamp,
                    chatId: widget.chatId,
                    chatType: widget.chatType,
                  ),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongColor,
                    content: Text(
                      context.l10n.messageSavedLabel,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongestColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongColor,
            content: Text(
              '${context.l10n.errorLabel}: ${current.message}',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
          ),
        );
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
                      title: context.l10n.errorLabel,
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => context.pop(),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ErrorState(
                      message:
                          '${context.l10n.failedToLoadChatDataMessage}: ${directSnapshot.error}',
                    ),
                  ),
                ),
              );
            } else if (!directSnapshot.hasData || directSnapshot.data == null) {
              return const Scaffold(body: Center(child: AppLoader()));
            }
            final directChat = directSnapshot.data!;

            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: SafeArea(
                  child: FutureBuilder<Widget>(
                    future: _buildNavBar(context, directChat),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return AppNavBar(title: context.l10n.errorLabel);
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return AppNavBar(title: context.l10n.loadingLabel);
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
                      title: context.l10n.errorLabel,
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => context.pop(),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ErrorState(
                      message:
                          '${context.l10n.failedToLoadChatDataMessage}: ${groupSnapshot.error}',
                    ),
                  ),
                ),
              );
            } else if (!groupSnapshot.hasData || groupSnapshot.data == null) {
              return const Scaffold(body: Center(child: AppLoader()));
            }
            final groupChat = groupSnapshot.data!;

            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: SafeArea(
                  child: FutureBuilder<Widget>(
                    future: _buildNavBar(context, groupChat),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return AppNavBar(title: context.l10n.errorLabel);
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return AppNavBar(title: context.l10n.loadingLabel);
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
