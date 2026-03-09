import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Chats extends StatefulWidget {
  final ValueNotifier<bool> editPressed;

  const Chats({super.key, required this.editPressed});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<Map<String, String>> _chatOtherNames = ValueNotifier({});

  void _fetchChatOtherNames(List<Chat> chats, AppController appController) {
    final currentOtherNames = _chatOtherNames.value;
    for (final chat in chats) {
      if (!currentOtherNames.containsKey(chat.id)) {
        appController.getOtherName(chat.id).then((name) {
          final updated = Map<String, String>.from(_chatOtherNames.value);
          updated[chat.id] = name.isNotEmpty ? name : 'Unknown';
          _chatOtherNames.value = updated;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return const ErrorState(message: 'User not authorized');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: spacing8,
        vertical: spacing16,
      ),
      child: Column(
        children: [
          AppSearchBar(
            onChanged: (value) {
              _searchQuery.value = value;
            },
            onSubmitted: (value) {
              _searchQuery.value = value;
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: context.appController.watchChatsForUser(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(width: 32, child: AppLoader()),
                  );
                } else if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Error loading chats: ${snapshot.error}',
                  );
                }

                final chats = snapshot.data ?? const [];

                if (chats.isEmpty) {
                  return EmptyState(
                    title: 'Nothing here. For now.',
                    body: 'This is where your chats go.',
                    buttonText: 'Start a chat',
                    onButtonPressed: () async {
                      final user = context.appState.user as AuthorizedUser;
                      final appController = context.appController;
                      final selectedUser = await UserPicker.pickUser(
                        context,
                        UserPickerFlag.friendsOnly.value,
                      );
                      if (selectedUser == null) return;

                      if (!mounted) return;
                      final chatId = await appController.createOrGetDirectChat(
                        currentUserId: user.id,
                        currentUserName: user.name,
                        otherUserId: selectedUser.id,
                        otherUserName: selectedUser.name,
                      );

                      if (!mounted) return;
                      context.push('/chats/$chatId');
                    },
                  );
                }

                _fetchChatOtherNames(chats, context.appController);
                return ValueListenableBuilder(
                  valueListenable: _searchQuery,
                  builder: (context, query, child) {
                    final q = query.trim().toLowerCase();
                    return ValueListenableBuilder<Map<String, String>>(
                      valueListenable: _chatOtherNames,
                      builder: (context, chatNames, _) {
                        final filteredChats = q.isEmpty
                            ? chats
                            : chats.where((chat) {
                                final name =
                                    chatNames[chat.id]?.toLowerCase() ?? '';
                                return name.contains(q);
                              }).toList();

                        if (filteredChats.isEmpty) {
                          return const EmptyState(
                            title: 'No chats found.',
                            body: 'Try adjusting your search query.',
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = filteredChats[index];
                            final messagesStream = context.appController
                                .watchMessagesForChat(chat.id);
                            return StreamBuilder(
                              stream: messagesStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: spacing4,
                                    ),
                                    child: SizedBox(
                                      width: 32,
                                      child: AppLoader(),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return ErrorState(
                                    message:
                                        'Error loading chat: ${snapshot.error}',
                                  );
                                }

                                final otherName =
                                    chatNames[chat.id] ?? 'Loading...';

                                Widget buildListItem({
                                  required String title,
                                  required String description,
                                  required AppListItemControl control,
                                  String? symbol,
                                  VoidCallback? onPressed,
                                  String? largeButtonText,
                                }) {
                                  return ValueListenableBuilder(
                                    valueListenable: widget.editPressed,
                                    builder: (context, editPressed, child) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: spacing4,
                                        ),
                                        child: SizedBox(
                                          height: 72,
                                          child: AppListItem(
                                            title: title,
                                            description: description,
                                            avatar: PlaceholderAvatar(
                                              size: AvatarSize.small,
                                            ),
                                            control: control,
                                            symbol: symbol,
                                            largeButtonText: largeButtonText,
                                            onPressed: onPressed,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }

                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return buildListItem(
                                    title: otherName,
                                    description: 'No messages yet',
                                    control: widget.editPressed.value
                                        ? AppListItemControl.largeButton
                                        : AppListItemControl.none,
                                    largeButtonText: widget.editPressed.value
                                        ? 'Delete'
                                        : null,
                                    onPressed: widget.editPressed.value
                                        ? () {
                                            context.appController.deleteChat(
                                              chat.id,
                                            );
                                          }
                                        : () {
                                            context.push('/chats/${chat.id}');
                                          },
                                  );
                                }

                                final lastSenderId =
                                    snapshot.data?.first.senderId;
                                if (lastSenderId != null &&
                                    lastSenderId != user.id &&
                                    chat.unreadCount > 0) {
                                  return buildListItem(
                                    title: otherName,
                                    description: chat.lastMessage,
                                    control: widget.editPressed.value
                                        ? AppListItemControl.largeButton
                                        : AppListItemControl.badge,
                                    symbol: widget.editPressed.value
                                        ? null
                                        : chat.unreadCount.toString(),
                                    largeButtonText: widget.editPressed.value
                                        ? 'Delete'
                                        : null,
                                    onPressed: widget.editPressed.value
                                        ? () {
                                            context.appController.deleteChat(
                                              chat.id,
                                            );
                                          }
                                        : () async {
                                            context.push('/chats/${chat.id}');
                                            if (mounted) {
                                              await context.appController
                                                  .updateChatUnreadCount(
                                                    chatId: chat.id,
                                                    unreadCount: 0,
                                                  );
                                            }
                                          },
                                  );
                                }

                                return buildListItem(
                                  title: otherName,
                                  description: chat.lastMessage,
                                  control: widget.editPressed.value
                                      ? AppListItemControl.largeButton
                                      : AppListItemControl.none,
                                  largeButtonText: widget.editPressed.value
                                      ? 'Delete'
                                      : null,
                                  onPressed: widget.editPressed.value
                                      ? () {
                                          context.appController.deleteChat(
                                            chat.id,
                                          );
                                        }
                                      : () {
                                          context.push('/chats/${chat.id}');
                                        },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }
}

class ChatsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> editPressed;

  const ChatsAppBar({super.key, required this.editPressed});

  @override
  State<ChatsAppBar> createState() => _ChatsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatsAppBarState extends State<ChatsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: widget.editPressed,
        builder: (context, value, child) {
          return AppNavBar(
            title: 'Chats',
            leftText: widget.editPressed.value ? 'Done' : 'Edit',
            rightIcon: AppIcons.create,
            onPressedLeft: () {
              widget.editPressed.value = !widget.editPressed.value;
            },
            onPressedRight: () async {
              final user = context.appState.user as AuthorizedUser;
              final appController = context.appController;
              final selectedUser = await UserPicker.pickUser(
                context,
                UserPickerFlag.friendsOnly.value,
              );
              if (selectedUser == null) return;

              if (!mounted) return;
              final chatId = await appController.createOrGetDirectChat(
                currentUserId: user.id,
                currentUserName: user.name,
                otherUserId: selectedUser.id,
                otherUserName: selectedUser.name,
              );

              if (!mounted) return;
              context.push('/chats/$chatId');
            },
          );
        },
      ),
    );
  }
}
