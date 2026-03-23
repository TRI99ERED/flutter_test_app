import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/features/home_screen/controllers/chat_controller.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
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

enum _MessageAction { reply, save, copy, delete }

class ChatScreen extends StatefulWidget {
  final String chatId;
  final ChatType chatType;

  const ChatScreen({super.key, required this.chatId, required this.chatType});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _chatController;
  String? _lastDirectChatId;
  String? _lastGroupChatId;
  String? _userId;
  bool _initialized = false;
  final _messageToReply = ValueNotifier<String>('');
  final _messageToReplyBody = ValueNotifier<String>('');
  final _scrollController = ScrollController();
  final _itemKeys = <String, GlobalKey>{};

  GlobalKey _getKeyForMessage(String id) {
    return _itemKeys.putIfAbsent(id, () => GlobalKey());
  }

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
      _userId = (context.appState.user is AuthorizedUser)
          ? (context.appState.user as AuthorizedUser).id
          : null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      });
    }
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
              appBar: _ChatScreenNavBar(chat: directChat),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(spacing8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(spacing8),
                          child: _ChatScreenMessageList(
                            chat: directChat,
                            messageToReply: _messageToReply,
                            messageToReplyBody: _messageToReplyBody,
                            scrollController: _scrollController,
                            getKeyForMessage: _getKeyForMessage,
                            itemKeys: _itemKeys,
                            chatType: widget.chatType,
                          ),
                        ),
                      ),
                      _ChatScreenMessageInput(
                        chat: directChat,
                        messageToReply: _messageToReply,
                        messageToReplyBody: _messageToReplyBody,
                      ),
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
              appBar: _ChatScreenNavBar(chat: groupChat),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(spacing8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(spacing8),
                          child: _ChatScreenMessageList(
                            chat: groupChat,
                            messageToReply: _messageToReply,
                            messageToReplyBody: _messageToReplyBody,
                            scrollController: _scrollController,
                            getKeyForMessage: _getKeyForMessage,
                            itemKeys: _itemKeys,
                            chatType: widget.chatType,
                          ),
                        ),
                      ),
                      _ChatScreenMessageInput(
                        chat: groupChat,
                        messageToReply: _messageToReply,
                        messageToReplyBody: _messageToReplyBody,
                      ),
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
    _messageToReply.dispose();
    _messageToReplyBody.dispose();
    _scrollController.dispose();
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

class _ChatScreenNavBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;

  const _ChatScreenNavBar({required this.chat});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appController = context.appController;
    final resolvedChatName = appController.watchAllUsers().first.then((users) {
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
          return FutureBuilder(
            future: resolvedChatName,
            builder: (context, asyncSnapshot) {
              return AppNavBar(
                title: asyncSnapshot.data ?? l10n.unknownChatterLabel,
                leftIcon: AppIcons.arrowLeft,
                rightImage: AppAvatar.avatarOrPlaceholder(
                  otherUser,
                  AvatarSize.small,
                ),
                onPressedLeft: () {
                  AppNavigator.of(context).pop();
                },
                onPressedRight: () {
                  UserProfile.show(
                    context,
                    otherUser,
                    mode: UserProfileMode.view,
                  );
                },
              );
            },
          );
        },
      );
    }
    if (chat is GroupChat && chat.participants.length > 2) {
      return AppNavBar(
        title: chat.name,
        leftIcon: AppIcons.arrowLeft,
        rightImage: AppAvatar.groupAvatarOrPlaceholder(
          chat as GroupChat,
          AvatarSize.small,
        ),
        onPressedLeft: () {
          AppNavigator.of(context).pop();
        },
        onPressedRight: () {
          ChatWizard.manageChat(context, mode: ChatWizardMode.edit, chat: chat);
        },
      );
    }
    return FutureBuilder(
      future: resolvedChatName,
      builder: (context, asyncSnapshot) {
        return AppNavBar(
          title: asyncSnapshot.data ?? l10n.unknownChatterLabel,
          leftIcon: AppIcons.arrowLeft,
          rightImage: const PlaceholderAvatar(size: AvatarSize.small),
          onPressedLeft: () {
            AppNavigator.of(context).pop();
          },
          onPressedRight: () {},
        );
      },
    );
  }
}

class _ChatScreenMessageInput extends StatefulWidget {
  final Chat chat;
  final ValueNotifier<String> messageToReply;
  final ValueNotifier<String> messageToReplyBody;

  const _ChatScreenMessageInput({
    required this.chat,
    required this.messageToReply,
    required this.messageToReplyBody,
  });

  @override
  State<_ChatScreenMessageInput> createState() =>
      _ChatScreenMessageInputState();
}

class _ChatScreenMessageInputState extends State<_ChatScreenMessageInput> {
  final _imageFiles = ValueNotifier<List<File>>([]);

  @override
  Widget build(BuildContext context) {
    final chatController = context.chatController!;

    if (widget.chat is DirectChat) {
      return StreamBuilder(
        stream: chatController.watchDirectChatUnreadCount(widget.chat.id),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorState(
              message:
                  '${context.l10n.failedToLoadUnreadCountMessage}: ${asyncSnapshot.error}',
            );
          }
          final unreadCount = asyncSnapshot.data ?? 0;
          return Column(
            children: [
              ValueListenableBuilder(
                valueListenable: widget.messageToReply,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    padding: const EdgeInsets.symmetric(horizontal: spacing8),
                    child: Row(
                      children: [
                        Text(
                          '${context.l10n.replyingToLabel}:',
                          style: TextStyle(
                            fontSize: bMSize,
                            fontWeight: bMWeight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        SizedBox(width: spacing8),
                        Expanded(
                          child: Text(
                            widget.messageToReplyBody.value,
                            style: TextStyle(
                              fontSize: bMSize,
                              fontWeight: bMWeight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            widget.messageToReply.value = '';
                            widget.messageToReplyBody.value = '';
                          },
                          icon: Icon(
                            AppIcons.close,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _imageFiles,
                builder: (context, value, child) {
                  return SizedBox(
                    height: _imageFiles.value.isEmpty ? 0 : 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.value.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(spacing8),
                              child: Image.file(
                                _imageFiles.value[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundStrongestColor,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  _imageFiles.value = List.from(
                                    _imageFiles.value,
                                  )..removeAt(index);
                                },
                                icon: Icon(
                                  AppIcons.delete,
                                  color: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.foregroundStrongestColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              AppMessageInput(
                onMorePressed: () {
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
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    showDragHandle: true,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: spacing16,
                        ),
                        child: Column(
                          children: [
                            AppListItem(
                              title: context.l10n.addImageLabel,
                              icon: AppIcons.image,
                              onPressed: () async {
                                _imageFiles.value = await context
                                    .chatController!
                                    .pickMessageImages(chatId: widget.chat.id);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                onSendPressed: (value) async {
                  final message = value.trim();
                  if (message.isEmpty && _imageFiles.value.isEmpty) {
                    return;
                  }
                  final user = context.appState.user as AuthorizedUser;
                  final appController = context.appController;
                  final replyId = widget.messageToReply.value.isNotEmpty
                      ? widget.messageToReply.value
                      : null;
                  final replyBody = widget.messageToReplyBody.value.isNotEmpty
                      ? widget.messageToReplyBody.value
                      : null;
                  await chatController.createDirectChatMessage(
                    chatId: widget.chat.id,
                    senderId: user.id,
                    senderName: user.name,
                    body: message,
                    imageFiles: _imageFiles.value,
                    replyId: replyId,
                    replyBody: replyBody,
                  );
                  _imageFiles.value = [];
                  widget.messageToReply.value = '';
                  widget.messageToReplyBody.value = '';
                  await chatController.updateDirectChatLastMessage(
                    chatId: widget.chat.id,
                    lastMessage: message,
                  );
                  final chatList = await chatController
                      .watchDirectChatsForUser(user.id)
                      .first;
                  final currentChat = chatList?.firstWhere(
                    (c) => c.id == widget.chat.id,
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
                      if (participant?.currentDirectChatId != widget.chat.id) {
                        await chatController.updateDirectChatUnreadCount(
                          chatId: widget.chat.id,
                          unreadCount: unreadCount + 1,
                        );
                      }
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    } else if (widget.chat is GroupChat) {
      return StreamBuilder(
        stream: chatController.watchGroupChatUnreadCounts(widget.chat.id),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorState(
              message:
                  '${context.l10n.failedToLoadUnreadCountsMessage}: ${asyncSnapshot.error}',
            );
          }
          final unreadCounts = asyncSnapshot.data ?? {};
          return Column(
            children: [
              ValueListenableBuilder(
                valueListenable: widget.messageToReply,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    padding: const EdgeInsets.symmetric(horizontal: spacing8),
                    child: Row(
                      children: [
                        Text(
                          '${context.l10n.replyingToLabel}:',
                          style: TextStyle(
                            fontSize: bMSize,
                            fontWeight: bMWeight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        SizedBox(width: spacing8),
                        Expanded(
                          child: Text(
                            widget.messageToReplyBody.value,
                            style: TextStyle(
                              fontSize: bMSize,
                              fontWeight: bMWeight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            widget.messageToReply.value = '';
                            widget.messageToReplyBody.value = '';
                          },
                          icon: Icon(
                            AppIcons.close,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _imageFiles,
                builder: (context, value, child) {
                  return SizedBox(
                    height: _imageFiles.value.isEmpty ? 0 : 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.value.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(spacing8),
                              child: Image.file(
                                _imageFiles.value[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundStrongestColor,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  _imageFiles.value = List.from(
                                    _imageFiles.value,
                                  )..removeAt(index);
                                },
                                icon: Icon(
                                  AppIcons.delete,
                                  color: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.foregroundStrongestColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
              AppMessageInput(
                onMorePressed: () {
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
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    showDragHandle: true,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: spacing16,
                        ),
                        child: Column(
                          children: [
                            AppListItem(
                              title: context.l10n.addImageLabel,
                              icon: AppIcons.image,
                              onPressed: () async {
                                _imageFiles.value = await context
                                    .chatController!
                                    .pickMessageImages(chatId: widget.chat.id);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                onSendPressed: (value) async {
                  final message = value.trim();
                  if (message.isEmpty && _imageFiles.value.isEmpty) {
                    return;
                  }
                  final user = context.appState.user as AuthorizedUser;
                  final appController = context.appController;
                  final replyId = widget.messageToReply.value.isNotEmpty
                      ? widget.messageToReply.value
                      : null;
                  final replyBody = widget.messageToReplyBody.value.isNotEmpty
                      ? widget.messageToReplyBody.value
                      : null;
                  await chatController.createGroupChatMessage(
                    chatId: widget.chat.id,
                    senderId: user.id,
                    senderName: user.name,
                    body: message,
                    imageFiles: _imageFiles.value,
                    replyId: replyId,
                    replyBody: replyBody,
                  );
                  _imageFiles.value = [];
                  widget.messageToReply.value = '';
                  widget.messageToReplyBody.value = '';
                  await chatController.updateGroupChatLastMessage(
                    chatId: widget.chat.id,
                    lastMessage: message,
                  );
                  final chatList = await chatController
                      .watchGroupChatsForUser(user.id)
                      .first;
                  final currentChat = chatList?.firstWhere(
                    (c) => c.id == widget.chat.id,
                  );
                  final users = await appController.watchAllUsers().first;
                  final updatedUnreadCounts = Map<String, int>.from(
                    unreadCounts,
                  );
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
                      if (participant?.currentGroupChatId != widget.chat.id) {
                        updatedUnreadCounts[participantId] =
                            (updatedUnreadCounts[participantId] ?? 0) + 1;
                      }
                    }
                  }
                  await chatController.updateGroupChatUnreadCounts(
                    chatId: widget.chat.id,
                    unreadCounts: updatedUnreadCounts,
                  );
                },
              ),
            ],
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _ChatScreenMessageList extends StatefulWidget {
  final Chat chat;
  final ValueNotifier<String> messageToReply;
  final ValueNotifier<String> messageToReplyBody;
  final ScrollController scrollController;
  final GlobalKey Function(String) getKeyForMessage;
  final Map<String, GlobalKey> itemKeys;
  final ChatType chatType;

  const _ChatScreenMessageList({
    required this.chat,
    required this.messageToReply,
    required this.messageToReplyBody,
    required this.scrollController,
    required this.getKeyForMessage,
    required this.itemKeys,
    required this.chatType,
  });

  @override
  State<_ChatScreenMessageList> createState() => _ChatScreenMessageListState();
}

class _ChatScreenMessageListState extends State<_ChatScreenMessageList> {
  late List<Message> _messages;
  final _highlightedMessageId = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    final appController = context.appController;
    final chatController = context.chatController!;
    final messageStream = widget.chat is DirectChat
        ? chatController.watchMessagesForDirectChat(widget.chat.id)
        : chatController.watchMessagesForGroupChat(widget.chat.id);
    final usersStream = appController.watchAllUsers();
    return StreamBuilder(
      stream: Rx.combineLatest2(
        messageStream,
        usersStream,
        (messages, users) => [messages, users],
      ),
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
        _messages = (snapshot.data?[0] ?? []) as List<Message>;
        final users = (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
        if (_messages.isEmpty) {
          return EmptyState(title: context.l10n.noMessagesYetLabel);
        }
        final messagesWithSenderNames =
            <({Message message, String senderName})>[];
        for (final message in _messages) {
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
          messagesWithSenderNames.add((
            message: message,
            senderName: sender.name,
          ));
        }
        return ListView.separated(
          controller: widget.scrollController,
          reverse: true,
          cacheExtent: 10000,
          itemCount: _messages.length,
          separatorBuilder: (context, index) {
            if (index < _messages.length - 1 &&
                _messages[index].timestamp.day !=
                    _messages[index + 1].timestamp.day) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: spacing8),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<AppTheme>()
                          ?.backgroundStrongColor
                          .withAlpha(192),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(spacing8),
                    child: Text(
                      context.l10n.dateSeparatorLabel(
                        _messages[index].timestamp.day,
                        switch (_messages[index].timestamp.month) {
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
                        _messages[index].timestamp.year,
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
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          itemBuilder: (context, index) {
            final message = _messages[index];
            bool? isRead;
            if (message.senderId ==
                (context.appState.user as AuthorizedUser).id) {
              if (widget.chat is DirectChat) {
                final sentMessages = _messages
                    .where(
                      (m) =>
                          m.senderId ==
                          (context.appState.user as AuthorizedUser).id,
                    )
                    .toList();
                final sentIndex = sentMessages.indexOf(message);
                isRead = sentIndex >= (widget.chat as DirectChat).unreadCount;
              } else if (widget.chat is GroupChat) {
                final sentMessages = _messages
                    .where(
                      (m) =>
                          m.senderId ==
                          (context.appState.user as AuthorizedUser).id,
                    )
                    .toList();
                final sentIndex = sentMessages.indexOf(message);
                final unreadCountsExcludingThisUser =
                    (widget.chat as GroupChat).unreadCounts
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

            String? replyBody;
            if (message.replyId.isNotEmpty) {
              final repliedMessage = _messages.firstWhere(
                (m) => m.id == message.replyId,
                orElse: () => Message(
                  id: '',
                  senderId: '',
                  body: '',
                  imageUrls: [],
                  timestamp: DateTime.now(),
                  replyId: '',
                  replyBody: '',
                ),
              );
              replyBody = repliedMessage.body;
            }

            if (index == _messages.length - 1) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacing8),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .extension<AppTheme>()
                              ?.backgroundStrongColor
                              .withAlpha(192),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(spacing8),
                        child: Text(
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
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _highlightedMessageId,
                    builder: (context, highlightedId, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: highlightedId == message.id
                            ? Theme.of(context)
                                  .extension<AppTheme>()
                                  ?.foregroundStrongestColor
                                  .withAlpha(32)
                            : Colors.transparent,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: widget.getKeyForMessage(message.id),
                      child: AlignedMessageBubble(
                        messagesWithSenderNames: messagesWithSenderNames,
                        index: index,
                        isFirstInSequence: true,
                        isRead: isRead,
                        imageUrls: message.imageUrls,
                        replyBody: replyBody ?? '',
                        timestamp: message.timestamp,
                        onTap: () {
                          _handleMessageTap(context, message);
                        },
                        onReplyTap: () {
                          _handleReplyTap(context, message);
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
            if ((index == 0 ||
                    _messages[index - 1].senderId !=
                        _messages[index].senderId) &&
                (index == _messages.length - 1 ||
                    _messages[index + 1].senderId !=
                        _messages[index].senderId)) {
              return ValueListenableBuilder(
                valueListenable: _highlightedMessageId,
                builder: (context, highlightedId, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: highlightedId == message.id
                        ? Theme.of(context)
                              .extension<AppTheme>()
                              ?.foregroundStrongestColor
                              .withAlpha(32)
                        : Colors.transparent,
                    child: child,
                  );
                },
                child: AlignedMessageBubble(
                  key: widget.getKeyForMessage(message.id),
                  messagesWithSenderNames: messagesWithSenderNames,
                  index: index,
                  isFirstInSequence: true,
                  isLastInSequence: true,
                  isRead: isRead,
                  imageUrls: message.imageUrls,
                  replyBody: replyBody ?? '',
                  timestamp: message.timestamp,
                  onTap: () {
                    _handleMessageTap(context, message);
                  },
                  onReplyTap: () {
                    _handleReplyTap(context, message);
                  },
                ),
              );
            }
            if (index == 0 ||
                _messages[index - 1].senderId != _messages[index].senderId) {
              return ValueListenableBuilder(
                valueListenable: _highlightedMessageId,
                builder: (context, highlightedId, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: highlightedId == message.id
                        ? Theme.of(context)
                              .extension<AppTheme>()
                              ?.foregroundStrongestColor
                              .withAlpha(32)
                        : Colors.transparent,
                    child: child,
                  );
                },
                child: AlignedMessageBubble(
                  key: widget.getKeyForMessage(message.id),
                  messagesWithSenderNames: messagesWithSenderNames,
                  index: index,
                  isLastInSequence: true,
                  isRead: isRead,
                  imageUrls: message.imageUrls,
                  replyBody: replyBody ?? '',
                  timestamp: message.timestamp,
                  onTap: () {
                    _handleMessageTap(context, message);
                  },
                  onReplyTap: () {
                    _handleReplyTap(context, message);
                  },
                ),
              );
            }
            if (index == _messages.length - 1 ||
                _messages[index + 1].senderId != _messages[index].senderId) {
              return ValueListenableBuilder(
                valueListenable: _highlightedMessageId,
                builder: (context, highlightedId, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: highlightedId == message.id
                        ? Theme.of(context)
                              .extension<AppTheme>()
                              ?.foregroundStrongestColor
                              .withAlpha(32)
                        : Colors.transparent,
                    child: child,
                  );
                },
                child: AlignedMessageBubble(
                  key: widget.getKeyForMessage(message.id),
                  messagesWithSenderNames: messagesWithSenderNames,
                  index: index,
                  isFirstInSequence: true,
                  isRead: isRead,
                  imageUrls: message.imageUrls,
                  replyBody: replyBody ?? '',
                  timestamp: message.timestamp,
                  onTap: () {
                    _handleMessageTap(context, message);
                  },
                  onReplyTap: () {
                    _handleReplyTap(context, message);
                  },
                ),
              );
            }
            return ValueListenableBuilder(
              valueListenable: _highlightedMessageId,
              builder: (context, highlightedId, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: highlightedId == message.id
                      ? Theme.of(context)
                            .extension<AppTheme>()
                            ?.foregroundStrongestColor
                            .withAlpha(32)
                      : Colors.transparent,
                  child: child,
                );
              },
              child: AlignedMessageBubble(
                key: widget.getKeyForMessage(message.id),
                messagesWithSenderNames: messagesWithSenderNames,
                index: index,
                isRead: isRead,
                imageUrls: message.imageUrls,
                replyBody: replyBody ?? '',
                timestamp: message.timestamp,
                onTap: () {
                  _handleMessageTap(context, message);
                },
                onReplyTap: () {
                  _handleReplyTap(context, message);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleMessageTap(BuildContext context, Message message) async {
    final chatController = context.chatController!;
    final result = await showModalBottomSheet(
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
              title: context.l10n.replyToMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.reply),
            ),
            AppListItem(
              title: context.l10n.saveMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.save),
            ),
            AppListItem(
              title: context.l10n.copyMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.copy),
            ),
            AppListItem(
              title: context.l10n.deleteMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.delete),
            ),
          ],
        );
      },
    );

    switch (result) {
      case _MessageAction.reply:
        widget.messageToReply.value = message.id;
        widget.messageToReplyBody.value = message.body;
        break;
      case _MessageAction.save:
        await chatController.saveMessage(
          SavedMessage(
            id: message.id,
            senderId: message.senderId,
            body: message.body,
            imageUrls: message.imageUrls,
            timestamp: message.timestamp,
            replyId: '',
            replyBody: '',
            chatId: widget.chat.id,
            chatType: widget.chat is DirectChat
                ? ChatType.direct
                : ChatType.group,
            savedAt: DateTime.now(),
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
        break;
      case _MessageAction.copy:
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
        break;
      case _MessageAction.delete:
        switch (widget.chatType) {
          case ChatType.direct:
            await chatController.deleteDirectChatMessage(
              widget.chat.id,
              message.id,
            );
            break;
          case ChatType.group:
            await chatController.deleteGroupChatMessage(
              widget.chat.id,
              message.id,
            );
            break;
        }
        break;
      default:
        break;
    }
  }

  void _highlightMessage(String messageId) {
    _highlightedMessageId.value = messageId;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _highlightedMessageId.value = null;
      }
    });
  }

  void _handleReplyTap(BuildContext context, Message message) {
    if (message.replyId.isEmpty) return;
    final index = _messages.indexWhere((m) => m.id == message.replyId);
    if (index == -1) return;

    final key = widget.getKeyForMessage(message.replyId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ).then((_) {
          _highlightMessage(message.replyId);
        });
      } else {
        final reverseIndex = _messages.length - 1 - index;
        const estimatedItemHeight = 120.0;
        final targetOffset = reverseIndex * estimatedItemHeight;
        final maxScroll = widget.scrollController.position.maxScrollExtent;
        widget.scrollController
            .animateTo(
              targetOffset.clamp(0.0, maxScroll),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .then((_) {
              _highlightMessage(message.replyId);
            });
      }
    });
  }

  @override
  void dispose() {
    _highlightedMessageId.dispose();
    super.dispose();
  }
}
