import 'dart:io';

import 'package:flutter/material.dart';
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

enum _MessageAction { goToDirectChat, goToGroupChat, delete }

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
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

                        final messages =
                            (snapshot.data?[0] ?? []) as List<SavedMessage>;
                        final users =
                            (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
                        if (messages.isEmpty) {
                          return EmptyState(
                            title: context.l10n.noSavedMessagesLabel,
                            body: context
                                .l10n
                                .yourSavedMessagesWillAppearHereLabel,
                          );
                        }
                        final messagesWithSenderNames =
                            <SavedMessage, String>{};
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
                                messages[index].savedAt.day !=
                                    messages[index + 1].savedAt.day) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: spacing8,
                                ),
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
                                        messages[index].savedAt.day,
                                        switch (messages[index].savedAt.month) {
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
                                        messages[index].savedAt.year,
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
                            final message = messages[index];
                            if (index == messages.length - 1) {
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
                                              ?.backgroundStrongColor
                                              .withAlpha(192),
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
                                  AlignedMessageBubble(
                                    messagesWithSenderNames:
                                        messagesWithSenderNames,
                                    index: index,
                                    isFirstInSequence: true,
                                    isRead: true,
                                    imageUrls: message.imageUrls,
                                    timestamp: message.timestamp,
                                    onTap: () {
                                      _handleMessageTap(context, message);
                                    },
                                  ),
                                ],
                              );
                            }
                            if ((index == 0 ||
                                    messages[index - 1].senderId !=
                                        messages[index].senderId) &&
                                (index == messages.length - 1 ||
                                    messages[index + 1].senderId !=
                                        messages[index].senderId)) {
                              return AlignedMessageBubble(
                                messagesWithSenderNames:
                                    messagesWithSenderNames,
                                index: index,
                                isFirstInSequence: true,
                                isLastInSequence: true,
                                isRead: true,
                                imageUrls: message.imageUrls,
                                timestamp: message.timestamp,
                                onTap: () {
                                  _handleMessageTap(context, message);
                                },
                              );
                            }
                            if (index == 0 ||
                                messages[index - 1].senderId !=
                                    messages[index].senderId) {
                              return AlignedMessageBubble(
                                messagesWithSenderNames:
                                    messagesWithSenderNames,
                                index: index,
                                isLastInSequence: true,
                                isRead: true,
                                imageUrls: message.imageUrls,
                                timestamp: message.timestamp,
                                onTap: () {
                                  _handleMessageTap(context, message);
                                },
                              );
                            }
                            if (index == messages.length - 1 ||
                                messages[index + 1].senderId !=
                                    messages[index].senderId) {
                              return AlignedMessageBubble(
                                messagesWithSenderNames:
                                    messagesWithSenderNames,
                                index: index,
                                isFirstInSequence: true,
                                isRead: true,
                                imageUrls: message.imageUrls,
                                timestamp: message.timestamp,
                                onTap: () {
                                  _handleMessageTap(context, message);
                                },
                              );
                            }
                            return AlignedMessageBubble(
                              messagesWithSenderNames: messagesWithSenderNames,
                              index: index,
                              isRead: true,
                              imageUrls: message.imageUrls,
                              timestamp: message.timestamp,
                              onTap: () {
                                _handleMessageTap(context, message);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                _SavedMessagesScreenMessageInput(),
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
      case _MessageAction.delete:
        chatController.deleteSavedMessage(message.id);
    }
  }
}

class _SavedMessagesScreenMessageInput extends StatefulWidget {
  const _SavedMessagesScreenMessageInput();

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
            );
            _imageFiles.value = [];
          },
        ),
      ],
    );
  }
}
