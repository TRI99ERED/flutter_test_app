import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/features/chat_screen/widgets/aligned_message_bubble.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_message_input.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final messageStream = context.appController.watchSavedMessages();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
      },
      child: Scaffold(
        appBar: AppNavBar(
          title: 'Saved Messages',
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            context.pop();
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
                      return const ErrorState(
                        message: 'Failed to load saved messages',
                      );
                    } else if (snapshot.hasData) {
                      final messages =
                          (snapshot.data?[0] ?? []) as List<SavedMessage>;
                      final users =
                          (snapshot.data?[1] ?? []) as List<AuthorizedUser>;
                      if (messages.isEmpty) {
                        return const EmptyState(
                          title: 'No saved messages',
                          body: 'Your saved messages will appear here.',
                        );
                      }
                      final messagesWithSenderNames = <SavedMessage, String>{};
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
                              onTap: () {
                                _handleMessageTap(context, messages[index]);
                              },
                            );
                          }
                          return AlignedMessageBubble(
                            messagesWithSenderNames: messagesWithSenderNames,
                            index: index,
                            onTap: () {
                              _handleMessageTap(context, messages[index]);
                            },
                          );
                        },
                      );
                    } else {
                      return const EmptyState(
                        title: 'No saved messages',
                        body: 'Your saved messages will appear here.',
                      );
                    }
                  },
                ),
              ),
              AppMessageInput(
                onSendPressed: (value) {
                  context.appController.createSavedMessage(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMessageTap(BuildContext context, SavedMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LightColor.light.color,
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
                  title: 'Go to direct chat',
                  onPressed: () {
                    context.pop();
                    context.push('/chats/direct/${message.chatId}');
                  },
                ),
                ChatType.group => AppListItem(
                  title: 'Go to group chat',
                  onPressed: () {
                    context.pop();
                    context.push('/chats/group/${message.chatId}');
                  },
                ),
              },
            AppListItem(
              title: 'Delete saved message',
              onPressed: () {
                context.appController.deleteSavedMessage(message.id);
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
