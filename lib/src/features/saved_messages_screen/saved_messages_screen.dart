import 'package:async/async.dart';
import 'package:flutter/material.dart';
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
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: StreamZip([messageStream, usersStream]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoader();
                    } else if (snapshot.hasError) {
                      return ErrorState(
                        message: context.l10n.failedToLoadSavedMessagesLabel,
                      );
                    } else if (snapshot.hasData) {
                      final messages =
                          (snapshot.data?[0] ?? []) as List<SavedMessage>;
                      final users =
                          (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
                      if (messages.isEmpty) {
                        return EmptyState(
                          title: context.l10n.noSavedMessagesLabel,
                          body:
                              context.l10n.yourSavedMessagesWillAppearHereLabel,
                        );
                      }
                      final messagesWithSenderNames = <SavedMessage, String>{};
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
                        padding: const EdgeInsets.all(spacing16),
                        itemCount: messages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: spacing12),
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
                              timestamp: messages[index].timestamp,
                              onTap: () {
                                _handleMessageTap(context, messages[index]);
                              },
                            );
                          }
                          if (index == 0 ||
                              messages[index - 1].senderId !=
                                  messages[index].senderId) {
                            return AlignedMessageBubble(
                              messagesWithSenderNames: messagesWithSenderNames,
                              index: index,
                              isLastInSequence: true,
                              timestamp: messages[index].timestamp,
                              onTap: () {
                                _handleMessageTap(context, messages[index]);
                              },
                            );
                          }
                          if (index == messages.length - 1 ||
                              messages[index + 1].senderId !=
                                  messages[index].senderId) {
                            return AlignedMessageBubble(
                              messagesWithSenderNames: messagesWithSenderNames,
                              index: index,
                              isFirstInSequence: true,
                              timestamp: messages[index].timestamp,
                              onTap: () {
                                _handleMessageTap(context, messages[index]);
                              },
                            );
                          }
                          return AlignedMessageBubble(
                            messagesWithSenderNames: messagesWithSenderNames,
                            index: index,
                            timestamp: messages[index].timestamp,
                            onTap: () {
                              _handleMessageTap(context, messages[index]);
                            },
                          );
                        },
                      );
                    } else {
                      return EmptyState(
                        title: context.l10n.noSavedMessagesLabel,
                        body: context.l10n.yourSavedMessagesWillAppearHereLabel,
                      );
                    }
                  },
                ),
              ),
              AppMessageInput(
                onSendPressed: (value) {
                  context.chatController!.createSavedMessage(value);
                },
              ),
            ],
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
