import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/chat_wizard.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Chats extends StatefulWidget {
  final ValueNotifier<bool> editPressed;

  const Chats({super.key, required this.editPressed});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final _searchQuery = ValueNotifier<String>('');

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
                  return Center(
                    child: ErrorState(
                      message: 'Error loading chats: ${snapshot.error}',
                    ),
                  );
                }

                final chats = snapshot.data ?? const [];

                if (chats.isEmpty) {
                  return EmptyState(
                    title: 'Nothing here. For now.',
                    body: 'This is where your chats go.',
                    buttonText: 'Start a chat',
                    onButtonPressed: () async {
                      final chat = await ChatWizard.manageChat(context);
                      if (chat == null) return;

                      if (!mounted) return;
                      context.push('/chats/${chat.id}');
                    },
                  );
                }

                return ValueListenableBuilder(
                  valueListenable: _searchQuery,
                  builder: (context, query, child) {
                    final q = query.trim().toLowerCase();

                    Future filterChats() async {
                      if (q.isEmpty) return chats;
                      List<Chat> result = [];
                      for (final chat in chats) {
                        final name = chat.name.toLowerCase();
                        if (name.isEmpty) {
                          final otherParticipantId = chat.participants
                              .firstWhere((id) => id != user.id);
                          final otherName = await context.appController
                              .getUserWithId(otherParticipantId)
                              .then((user) => user.name.toLowerCase());
                          if (otherName.contains(q)) {
                            result.add(chat);
                          }
                        } else if (name.contains(q)) {
                          result.add(chat);
                        }
                      }
                      return result;
                    }

                    return FutureBuilder(
                      future: filterChats(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: AppLoader());
                        }
                        final filteredChats = snapshot.data! as List<Chat>;
                        if (filteredChats.isEmpty) {
                          return const EmptyState(
                            title: 'No chats found.',
                            body: 'Try adjusting your search query.',
                          );
                        }

                        return ValueListenableBuilder(
                          valueListenable: widget.editPressed,
                          builder: (context, value, child) {
                            return ListView.builder(
                              itemCount: filteredChats.length,
                              itemBuilder: (context, index) {
                                final chat = filteredChats[index];

                                return StreamBuilder(
                                  stream: context.appController.watchChatWithId(
                                    chat.id,
                                  ),
                                  builder: (context, chatSnapshot) {
                                    final resolvedChatNameFuture =
                                        chatSnapshot
                                                .data
                                                ?.participants
                                                .length ==
                                            2
                                        ? context.appController
                                              .watchUserWithId(
                                                chatSnapshot.data!.participants
                                                    .firstWhere(
                                                      (id) => id != user.id,
                                                    ),
                                              )
                                              .first
                                              .then((user) => user.name)
                                        : Future.value(
                                            chatSnapshot.data?.name ?? '',
                                          );

                                    return FutureBuilder(
                                      future: resolvedChatNameFuture,
                                      builder: (context, nameSnapshot) {
                                        final resolvedChatName =
                                            nameSnapshot.data ?? '';

                                        return StreamBuilder(
                                          stream: context.appController
                                              .watchMessagesForChat(chat.id),
                                          builder: (context, snapshot) {
                                            Widget buildListItem({
                                              required String title,
                                              required String description,
                                              required AppListItemControl
                                              control,
                                              String? symbol,
                                              VoidCallback? onPressed,
                                              String? largeButtonText,
                                            }) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: spacing4,
                                                    ),
                                                child: SizedBox(
                                                  height: 72,
                                                  child: StreamBuilder(
                                                    stream: context
                                                        .appController
                                                        .watchUserWithId(
                                                          chat.participants
                                                              .firstWhere(
                                                                (id) =>
                                                                    id !=
                                                                    user.id,
                                                              ),
                                                        ),
                                                    builder:
                                                        (
                                                          context,
                                                          asyncSnapshot,
                                                        ) {
                                                          final otherUser =
                                                              asyncSnapshot
                                                                  .data;

                                                          return AppListItem(
                                                            title: title,
                                                            description:
                                                                description,
                                                            avatar:
                                                                AppAvatar.avatarOrPlaceholder(
                                                                  otherUser,
                                                                  AvatarSize
                                                                      .small,
                                                                ),
                                                            control: control,
                                                            symbol: symbol,
                                                            largeButtonText:
                                                                largeButtonText,
                                                            onPressed:
                                                                onPressed,
                                                          );
                                                        },
                                                  ),
                                                ),
                                              );
                                            }

                                            final canEdit =
                                                widget.editPressed.value &&
                                                (chat.groupOwnerId == user.id ||
                                                    chat.groupOwnerId == '');

                                            if (snapshot.data == null ||
                                                snapshot.data!.isEmpty) {
                                              return buildListItem(
                                                title: resolvedChatName,
                                                description: 'No messages yet',
                                                control: canEdit
                                                    ? AppListItemControl
                                                          .largeButton
                                                    : AppListItemControl.none,
                                                largeButtonText: canEdit
                                                    ? 'Delete'
                                                    : null,
                                                onPressed: canEdit
                                                    ? () {
                                                        context.appController
                                                            .deleteChat(
                                                              chat.id,
                                                            );
                                                      }
                                                    : () {
                                                        if (!mounted) return;
                                                        context.push(
                                                          '/chats/${chat.id}',
                                                        );
                                                      },
                                              );
                                            }

                                            final lastSenderId =
                                                snapshot.data?.first.senderId;
                                            if (lastSenderId != null &&
                                                lastSenderId != user.id &&
                                                chat.unreadCount > 0) {
                                              return buildListItem(
                                                title: resolvedChatName,
                                                description: chat.lastMessage,
                                                control: canEdit
                                                    ? AppListItemControl
                                                          .largeButton
                                                    : AppListItemControl.badge,
                                                symbol: canEdit
                                                    ? null
                                                    : chat.unreadCount
                                                          .toString(),
                                                largeButtonText: canEdit
                                                    ? 'Delete'
                                                    : null,
                                                onPressed:
                                                    widget.editPressed.value
                                                    ? () {
                                                        context.appController
                                                            .deleteChat(
                                                              chat.id,
                                                            );
                                                      }
                                                    : () async {
                                                        if (!mounted) return;
                                                        context.push(
                                                          '/chats/${chat.id}',
                                                        );
                                                        await context
                                                            .appController
                                                            .updateChatUnreadCount(
                                                              chatId: chat.id,
                                                              unreadCount: 0,
                                                            );
                                                      },
                                              );
                                            }

                                            return buildListItem(
                                              title: resolvedChatName,
                                              description: chat.lastMessage,
                                              control: canEdit
                                                  ? AppListItemControl
                                                        .largeButton
                                                  : AppListItemControl.none,
                                              largeButtonText: canEdit
                                                  ? 'Delete'
                                                  : null,
                                              onPressed: canEdit
                                                  ? () {
                                                      context.appController
                                                          .deleteChat(chat.id);
                                                    }
                                                  : () {
                                                      if (!mounted) return;
                                                      context.push(
                                                        '/chats/${chat.id}',
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
              final chat = await ChatWizard.manageChat(context);
              if (chat == null) return;

              if (!mounted) return;
              context.push('/chats/${chat.id}');
            },
          );
        },
      ),
    );
  }
}
