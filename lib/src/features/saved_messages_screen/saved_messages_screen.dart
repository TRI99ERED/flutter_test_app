import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/features/themes/styles.dart';

enum _MessageAction { goToDirectChat, goToGroupChat, reply, copy, delete }

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  final _messageToReply = ValueNotifier<String>('');
  final _messageToReplyBody = ValueNotifier<String>('');
  final _scrollController = ScrollController();
  final _itemKeys = <String, GlobalKey>{};
  List<SavedMessage> _messages = [];
  final _highlightedMessageId = ValueNotifier<String?>(null);

  GlobalKey _getKeyForMessage(String id) {
    return _itemKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _highlightMessage(String messageId) {
    _highlightedMessageId.value = messageId;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _highlightedMessageId.value = null;
      }
    });
  }

  @override
  void dispose() {
    _messageToReply.dispose();
    _messageToReplyBody.dispose();
    _scrollController.dispose();
    _highlightedMessageId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = context.chatController!.watchSavedMessages();
    final usersStream = context.appController.watchAllUsers();

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
      child: Scaffold(
        appBar: AppNavBar(
          title: context.l10n.savedMessagesTitle,
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            AppNavigator.of(context).pop();
          },
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
                      stream: Rx.combineLatest2(
                        messageStream,
                        usersStream,
                        (messages, users) => [messages, users],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ErrorState(
                            message:
                                context.l10n.failedToLoadSavedMessagesLabel,
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: AppLoader());
                        }

                        _messages =
                            (snapshot.data?[0] ?? []) as List<SavedMessage>;
                        final users =
                            (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
                        if (_messages.isEmpty) {
                          return EmptyState(
                            title: context.l10n.noSavedMessagesLabel,
                            body: context
                                .l10n
                                .yourSavedMessagesWillAppearHereLabel,
                          );
                        }
                        final messagesWithSenderNames =
                            <({SavedMessage message, String senderName})>[];
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
                          controller: _scrollController,
                          reverse: true,
                          cacheExtent: 10000,
                          itemCount: _messages.length,
                          separatorBuilder: (context, index) {
                            if (index < _messages.length - 1 &&
                                _messages[index].savedAt.day !=
                                    _messages[index + 1].savedAt.day) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: spacing8,
                                ),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.backgroundStrongColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(spacing8),
                                    child: Text(
                                      context.l10n.dateSeparatorLabel(
                                        _messages[index].savedAt.day,
                                        switch (_messages[index]
                                            .savedAt
                                            .month) {
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
                                        _messages[index].savedAt.year,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: cMSize,
                                        fontWeight: cMWeight,
                                        color: Theme.of(context)
                                            .extension<AppTheme>()
                                            ?.foregroundStrongestColor,
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
                            if (index == _messages.length - 1) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: spacing8,
                                    ),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .extension<AppTheme>()
                                              ?.backgroundStrongColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(spacing8),
                                        child: Text(
                                          context.l10n.dateSeparatorLabel(
                                            message.savedAt.day,
                                            switch (message.savedAt.month) {
                                              1 => context.l10n.ofJanuaryLabel,
                                              2 => context.l10n.ofFebruaryLabel,
                                              3 => context.l10n.ofMarchLabel,
                                              4 => context.l10n.ofAprilLabel,
                                              5 => context.l10n.ofMayLabel,
                                              6 => context.l10n.ofJuneLabel,
                                              7 => context.l10n.ofJulyLabel,
                                              8 => context.l10n.ofAugustLabel,
                                              9 =>
                                                context.l10n.ofSeptemberLabel,
                                              10 => context.l10n.ofOctoberLabel,
                                              11 =>
                                                context.l10n.ofNovemberLabel,
                                              12 =>
                                                context.l10n.ofDecemberLabel,
                                              _ => '',
                                            },
                                            message.savedAt.year,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: cMSize,
                                            fontWeight: cMWeight,
                                            color: Theme.of(context)
                                                .extension<AppTheme>()
                                                ?.foregroundStrongestColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: _highlightedMessageId,
                                    builder: (context, value, child) {
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        color:
                                            _highlightedMessageId.value ==
                                                message.id
                                            ? Theme.of(context)
                                                  .extension<AppTheme>()
                                                  ?.foregroundStrongestColor
                                                  .withAlpha(32)
                                            : Colors.transparent,
                                        child: KeyedSubtree(
                                          key: _getKeyForMessage(message.id),
                                          child: AlignedMessageBubble(
                                            messagesWithSenderNames:
                                                messagesWithSenderNames,
                                            index: index,
                                            isFirstInSequence: true,
                                            isRead: true,
                                            imageUrls: message.imageUrls,
                                            replyBody: message.replyBody,
                                            timestamp: message.timestamp,
                                            onTap: () {
                                              _handleMessageTap(
                                                context,
                                                message,
                                              );
                                            },
                                            onReplyTap: () {
                                              _handleReplyTap(context, message);
                                            },
                                          ),
                                        ),
                                      );
                                    },
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
                                builder: (context, value, child) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    color:
                                        _highlightedMessageId.value ==
                                            message.id
                                        ? Theme.of(context)
                                              .extension<AppTheme>()
                                              ?.foregroundStrongestColor
                                              .withAlpha(32)
                                        : Colors.transparent,
                                    child: AlignedMessageBubble(
                                      key: _getKeyForMessage(message.id),
                                      messagesWithSenderNames:
                                          messagesWithSenderNames,
                                      index: index,
                                      isFirstInSequence: true,
                                      isLastInSequence: true,
                                      isRead: true,
                                      imageUrls: message.imageUrls,
                                      replyBody: message.replyBody,
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
                            }
                            if (index == 0 ||
                                _messages[index - 1].senderId !=
                                    _messages[index].senderId) {
                              return ValueListenableBuilder(
                                valueListenable: _highlightedMessageId,
                                builder: (context, value, child) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    color:
                                        _highlightedMessageId.value ==
                                            message.id
                                        ? Theme.of(context)
                                              .extension<AppTheme>()
                                              ?.foregroundStrongestColor
                                              .withAlpha(32)
                                        : Colors.transparent,
                                    child: AlignedMessageBubble(
                                      key: _getKeyForMessage(message.id),
                                      messagesWithSenderNames:
                                          messagesWithSenderNames,
                                      index: index,
                                      isLastInSequence: true,
                                      isRead: true,
                                      imageUrls: message.imageUrls,
                                      replyBody: message.replyBody,
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
                            }
                            if (index == _messages.length - 1 ||
                                _messages[index + 1].senderId !=
                                    _messages[index].senderId) {
                              return ValueListenableBuilder(
                                valueListenable: _highlightedMessageId,
                                builder: (context, value, child) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    color:
                                        _highlightedMessageId.value ==
                                            message.id
                                        ? Theme.of(context)
                                              .extension<AppTheme>()
                                              ?.foregroundStrongestColor
                                              .withAlpha(32)
                                        : Colors.transparent,
                                    child: AlignedMessageBubble(
                                      key: _getKeyForMessage(message.id),
                                      messagesWithSenderNames:
                                          messagesWithSenderNames,
                                      index: index,
                                      isFirstInSequence: true,
                                      isRead: true,
                                      imageUrls: message.imageUrls,
                                      replyBody: message.replyBody,
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
                            }
                            return ValueListenableBuilder(
                              valueListenable: _highlightedMessageId,
                              builder: (context, value, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  color:
                                      _highlightedMessageId.value == message.id
                                      ? Theme.of(context)
                                            .extension<AppTheme>()
                                            ?.foregroundStrongestColor
                                            .withAlpha(32)
                                      : Colors.transparent,
                                  child: AlignedMessageBubble(
                                    key: _getKeyForMessage(message.id),
                                    messagesWithSenderNames:
                                        messagesWithSenderNames,
                                    index: index,
                                    isRead: true,
                                    imageUrls: message.imageUrls,
                                    replyBody: message.replyBody,
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
                      },
                    ),
                  ),
                ),
                _SavedMessagesScreenMessageInput(
                  messageToReply: _messageToReply,
                  messageToReplyBody: _messageToReplyBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMessageTap(
    BuildContext context,
    SavedMessage message,
  ) async {
    final navigator = AppNavigator.of(context);
    final chatController = context.chatController!;
    final action = await showModalBottomSheet<_MessageAction>(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).extension<AppTheme>()?.backgroundStrongColor,
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
            if (message.chatId.isNotEmpty)
              switch (message.chatType) {
                ChatType.direct => AppListItem(
                  title: context.l10n.goToDirectChatLabel,
                  onPressed: () =>
                      Navigator.of(context).pop(_MessageAction.goToDirectChat),
                ),
                ChatType.group => AppListItem(
                  title: context.l10n.goToGroupChatLabel,
                  onPressed: () =>
                      Navigator.of(context).pop(_MessageAction.goToGroupChat),
                ),
              },
            AppListItem(
              title: context.l10n.replyToMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.reply),
            ),
            AppListItem(
              title: context.l10n.copyMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.copy),
            ),
            AppListItem(
              title: context.l10n.deleteSavedMessageLabel,
              onPressed: () => Navigator.of(context).pop(_MessageAction.delete),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _MessageAction.goToDirectChat:
        navigator.push(
          ChatPage(chatId: message.chatId, chatType: ChatType.direct),
        );
      case _MessageAction.goToGroupChat:
        navigator.push(
          ChatPage(chatId: message.chatId, chatType: ChatType.group),
        );
      case _MessageAction.reply:
        _messageToReply.value = message.id;
        _messageToReplyBody.value = message.body;
      case _MessageAction.copy:
        Clipboard.setData(ClipboardData(text: message.body));
      case _MessageAction.delete:
        chatController.deleteSavedMessage(message.id);
    }
  }

  void _handleReplyTap(BuildContext context, SavedMessage message) {
    if (message.replyId.isEmpty) return;
    final index = _messages.indexWhere((m) => m.id == message.replyId);
    if (index == -1) return;

    final key = _getKeyForMessage(message.replyId);

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
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController
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
}

class _SavedMessagesScreenMessageInput extends StatefulWidget {
  final ValueNotifier<String> messageToReply;
  final ValueNotifier<String> messageToReplyBody;

  const _SavedMessagesScreenMessageInput({
    required this.messageToReply,
    required this.messageToReplyBody,
  });

  @override
  State<_SavedMessagesScreenMessageInput> createState() =>
      _SavedMessagesScreenMessageInputState();
}

class _SavedMessagesScreenMessageInputState
    extends State<_SavedMessagesScreenMessageInput> {
  final _imageFiles = ValueNotifier<List<File>>([]);

  @override
  Widget build(BuildContext context) {
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
              height: _imageFiles.value.isNotEmpty ? 100 : 0,
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
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.backgroundStrongestColor,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            _imageFiles.value = List.from(_imageFiles.value)
                              ..removeAt(index);
                          },
                          icon: Icon(
                            AppIcons.delete,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.3,
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: spacing16),
                  child: Column(
                    children: [
                      AppListItem(
                        title: context.l10n.addImageLabel,
                        icon: AppIcons.image,
                        onPressed: () async {
                          _imageFiles.value = await context.chatController!
                              .pickSavedMessageImages();
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
          onSendPressed: (value) {
            value = value.trim();
            if (value.isEmpty && _imageFiles.value.isEmpty) return;
            context.chatController!.createSavedMessage(
              value,
              _imageFiles.value,
              widget.messageToReply.value.isNotEmpty
                  ? widget.messageToReply.value
                  : null,
              widget.messageToReply.value.isNotEmpty
                  ? widget.messageToReplyBody.value
                  : null,
            );
            _imageFiles.value = [];
            widget.messageToReply.value = '';
            widget.messageToReplyBody.value = '';
          },
        ),
      ],
    );
  }
}
