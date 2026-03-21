import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/src/features/home_screen/controllers/chat_controller.dart';
import 'package:test_app/src/router/app_navigator.dart';
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
  late final AppController _appController;
  late final ChatController _chatController;
  String? _lastDirectChatId;
  String? _lastGroupChatId;
  String? _userId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _chatController = context.chatController!;
      _appController = context.appController;
      _userId = (context.appState.user is AuthorizedUser)
          ? (context.appState.user as AuthorizedUser).id
          : null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initializeChat();
      });
    }
  }

  Future<void> _initializeChat() async {
    if (_userId == null) return;
    switch (widget.chatType) {
      case ChatType.direct:
        final directChat = await _chatController
            .watchDirectChatWithId(widget.chatId)
            .firstWhere((chat) => chat != null);
        if (!mounted) return;
        final lastMessage = await _chatController
            .watchMessagesForDirectChat(widget.chatId)
            .first
            .timeout(const Duration(seconds: 10))
            .then((messages) => messages?.first)
            .catchError((_) => null);
        if (!mounted) return;
        final lastSenderId = lastMessage?.senderId;
        final unreadCount = directChat?.unreadCount ?? 0;

        if (lastSenderId != null &&
            lastSenderId != _userId &&
            unreadCount > 0) {
          await _chatController.updateDirectChatUnreadCount(
            chatId: widget.chatId,
            unreadCount: 0,
          );
        }

        if (_lastDirectChatId != widget.chatId) {
          _chatController.updateUserCurrentDirectChatId(
            userId: _userId!,
            currentDirectChatId: widget.chatId,
          );
          _lastDirectChatId = widget.chatId;
        }
        break;
      case ChatType.group:
        final groupChat = await _chatController
            .watchGroupChatWithId(widget.chatId)
            .firstWhere((chat) => chat != null);
        if (!mounted) return;
        final lastMessage = await _chatController
            .watchMessagesForGroupChat(widget.chatId)
            .first
            .timeout(const Duration(seconds: 10))
            .then((messages) => messages?.first)
            .catchError((_) => null);
        if (!mounted) return;
        final lastSenderId = lastMessage?.senderId;
        final unreadCount = groupChat?.unreadCounts[_userId] ?? 0;

        if (lastSenderId != null &&
            lastSenderId != _userId &&
            unreadCount > 0) {
          await _chatController.updateGroupChatCurrentUserUnreadCount(
            chatId: widget.chatId,
            unreadCount: 0,
          );
        }

        if (_lastGroupChatId != widget.chatId) {
          _chatController.updateUserCurrentGroupChatId(
            userId: _userId!,
            currentGroupChatId: widget.chatId,
          );
          _lastGroupChatId = widget.chatId;
        }
        break;
    }
  }

  Future<Widget> _buildNavBar(BuildContext context, Chat chat) async {
    final l10n = context.l10n;
    final appController = context.appController;
    final resolvedChatName = await appController.watchAllUsers().first.then((
      users,
    ) {
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
              onPressedLeft: () => AppNavigator.of(context).pop(),
              rightImage: null,
            );
          }
          final otherUser = asyncSnapshot.data;
          if (otherUser == null) {
            return AppNavBar(
              title: l10n.userNotFoundLabel,
              leftIcon: AppIcons.arrowLeft,
              onPressedLeft: () {
                AppNavigator.of(context).pop();
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
              AppNavigator.of(context).pop();
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
          AppNavigator.of(context).pop();
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
        AppNavigator.of(context).pop();
      },
      onPressedRight: () {},
    );
  }

  Widget _buildMessageInput(BuildContext context, Chat chat) {
    if (chat is DirectChat) {
      return StreamBuilder(
        stream: _chatController.watchDirectChatUnreadCount(widget.chatId),
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
              final message = value.trim();
              if (message.isEmpty) {
                return;
              }
              final user = context.appState.user as AuthorizedUser;
              final appController = context.appController;
              await _chatController.createDirectChatMessage(
                chatId: widget.chatId,
                senderId: user.id,
                senderName: user.name,
                body: message,
              );
              await _chatController.updateDirectChatLastMessage(
                chatId: widget.chatId,
                lastMessage: message,
              );
              final chatList = await _chatController
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
                    await _chatController.updateDirectChatUnreadCount(
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
        stream: _chatController.watchGroupChatUnreadCounts(widget.chatId),
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
              final message = value.trim();
              if (message.isEmpty) {
                return;
              }
              final user = context.appState.user as AuthorizedUser;
              final appController = context.appController;
              await _chatController.createGroupChatMessage(
                chatId: widget.chatId,
                senderId: user.id,
                senderName: user.name,
                body: message,
              );
              await _chatController.updateGroupChatLastMessage(
                chatId: widget.chatId,
                lastMessage: message,
              );
              final chatList = await _chatController
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
              await _chatController.updateGroupChatUnreadCounts(
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
        ? _chatController.watchMessagesForDirectChat(widget.chatId)
        : _chatController.watchMessagesForGroupChat(widget.chatId);
    final usersStream = _appController.watchAllUsers();
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
        return ListView.separated(
          reverse: true,
          itemCount: messages.length,
          separatorBuilder: (context, index) {
            if (index < messages.length - 1 &&
                messages[index].timestamp.day !=
                    messages[index + 1].timestamp.day) {
              return Text(
                context.l10n.dateSeparatorLabel(
                  messages[index].timestamp.day,
                  switch (messages[index].timestamp.month) {
                    1 => context.l10n.ofJanuaryLabel,
                    2 => context.l10n.ofFebruaryLabel,
                    3 => context.l10n.ofMarchLabel,
                    4 => context.l10n.ofAprilLabel,
                    5 => context.l10n.ofMayLabel,
                    6 => context.l10n.ofJuneLabel,
                    7 => context.l10n.ofJulyLabel,
                    8 => context.l10n.ofAugustLabel,
                    9 => context.l10n.ofSeptemberLabel,
                    10 => context.l10n.ofOctoberLabel,
                    11 => context.l10n.ofNovemberLabel,
                    12 => context.l10n.ofDecemberLabel,
                    _ => '',
                  },
                  messages[index].timestamp.year,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: cMSize,
                  fontWeight: cMWeight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              );
            }
            return const SizedBox.shrink();
          },
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
            if (index == messages.length - 1) {
              return Column(
                children: [
                  Text(
                    context.l10n.dateSeparatorLabel(
                      message.timestamp.day,
                      switch (message.timestamp.month) {
                        1 => context.l10n.ofJanuaryLabel,
                        2 => context.l10n.ofFebruaryLabel,
                        3 => context.l10n.ofMarchLabel,
                        4 => context.l10n.ofAprilLabel,
                        5 => context.l10n.ofMayLabel,
                        6 => context.l10n.ofJuneLabel,
                        7 => context.l10n.ofJulyLabel,
                        8 => context.l10n.ofAugustLabel,
                        9 => context.l10n.ofSeptemberLabel,
                        10 => context.l10n.ofOctoberLabel,
                        11 => context.l10n.ofNovemberLabel,
                        12 => context.l10n.ofDecemberLabel,
                        _ => '',
                      },
                      message.timestamp.year,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: cMSize,
                      fontWeight: cMWeight,
                      color: Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongestColor,
                    ),
                  ),
                  AlignedMessageBubble(
                    messagesWithSenderNames: messagesWithSenderNames,
                    index: index,
                    isFirstInSequence: true,
                    isRead: isRead,
                    timestamp: message.timestamp,
                    onTap: () {
                      _handleMessageTap(context, message);
                    },
                  ),
                ],
              );
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
                timestamp: message.timestamp,
                onTap: () {
                  _handleMessageTap(context, message);
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
                timestamp: message.timestamp,
                onTap: () {
                  _handleMessageTap(context, message);
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
                timestamp: message.timestamp,
                onTap: () {
                  _handleMessageTap(context, message);
                },
              );
            }
            return AlignedMessageBubble(
              messagesWithSenderNames: messagesWithSenderNames,
              index: index,
              isRead: isRead,
              timestamp: message.timestamp,
              onTap: () {
                _handleMessageTap(context, message);
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
                await _chatController.saveMessage(
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
                        fontSize: cMSize,
                        fontWeight: cMWeight,
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongestColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            AppListItem(
              title: context.l10n.copyMessageLabel,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message.body));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongColor,
                    content: Text(
                      context.l10n.messageCopiedLabel,
                      style: TextStyle(
                        fontSize: cMSize,
                        fontWeight: cMWeight,
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
                fontSize: cMSize,
                fontWeight: cMWeight,
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
          stream: _chatController.watchDirectChatWithId(widget.chatId),
          builder: (context, directSnapshot) {
            if (directSnapshot.hasError) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: AppNavBar(
                      title: context.l10n.errorLabel,
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => AppNavigator.of(context).pop(),
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
          stream: _chatController.watchGroupChatWithId(widget.chatId),
          builder: (context, groupSnapshot) {
            if (groupSnapshot.hasError) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: AppNavBar(
                      title: context.l10n.errorLabel,
                      leftIcon: AppIcons.arrowLeft,
                      onPressedLeft: () => AppNavigator.of(context).pop(),
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
        if (_userId != null && _lastDirectChatId != null) {
          _chatController.updateUserCurrentDirectChatId(
            userId: _userId!,
            currentDirectChatId: '',
          );
        }
        break;
      case ChatType.group:
        if (_userId != null && _lastGroupChatId != null) {
          _chatController.updateUserCurrentGroupChatId(
            userId: _userId!,
            currentGroupChatId: '',
          );
        }
        break;
    }
    super.dispose();
  }
}
