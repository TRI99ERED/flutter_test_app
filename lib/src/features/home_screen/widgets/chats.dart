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
            onChanged: (value) => _searchQuery.value = value,
            onSubmitted: (value) => _searchQuery.value = value,
          ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: context.appController.watchAllChatsForUser(user.id),
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
                      if (!mounted || chat == null) return;
                      context.push('/chats/${chat.id}');
                    },
                  );
                }
                return ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, query, child) {
                    return _FilteredChatsList(
                      chats: chats,
                      query: query,
                      user: user,
                      editPressed: widget.editPressed,
                      mounted: mounted,
                      context: context,
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
}

class _FilteredChatsList extends StatelessWidget {
  final List<Chat> chats;
  final String query;
  final AuthorizedUser user;
  final ValueNotifier<bool> editPressed;
  final bool mounted;
  final BuildContext context;

  const _FilteredChatsList({
    required this.chats,
    required this.query,
    required this.user,
    required this.editPressed,
    required this.mounted,
    required this.context,
  });

  Future<List<Chat>> _filterChats() async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return chats;
    List<Chat> result = [];
    for (final chat in chats) {
      final name = chat.name.toLowerCase();
      if (name.isEmpty) {
        final otherParticipantId = chat.participants.firstWhere(
          (id) => id != user.id,
          orElse: () => '',
        );
        if (otherParticipantId.isNotEmpty) {
          final otherName = await context.appController
              .watchUserWithId(otherParticipantId)
              .first
              .then((user) => user.name.toLowerCase());
          if (otherName.contains(q)) {
            result.add(chat);
          }
        }
      } else if (name.contains(q)) {
        result.add(chat);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chat>>(
      future: _filterChats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: AppLoader());
        }
        final filteredChats = snapshot.data!;
        if (filteredChats.isEmpty) {
          return const EmptyState(
            title: 'No chats found.',
            body: 'Try adjusting your search query.',
          );
        }
        return ValueListenableBuilder<bool>(
          valueListenable: editPressed,
          builder: (context, canEdit, child) {
            return ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return _ChatListItem(
                  chat: chat,
                  user: user,
                  canEdit: canEdit,
                  mounted: mounted,
                  context: this.context,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Chat chat;
  final AuthorizedUser user;
  final bool canEdit;
  final bool mounted;
  final BuildContext context;

  const _ChatListItem({
    required this.chat,
    required this.user,
    required this.canEdit,
    required this.mounted,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: this.context.appController.watchChatWithId(chat.id),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 32, child: AppLoader()));
        } else if (chatSnapshot.hasError) {
          return Center(
            child: ErrorState(
              message: 'Error loading chat: ${chatSnapshot.error}',
            ),
          );
        }
        final participants = chatSnapshot.data?.participants ?? [];
        final otherParticipantId = participants.firstWhere(
          (id) => id != user.id,
          orElse: () => '',
        );
        final resolvedChatNameFuture =
            participants.length == 2 && otherParticipantId.isNotEmpty
            ? this.context.appController
                  .watchUserWithId(otherParticipantId)
                  .first
                  .then((user) => user.name)
            : Future.value(chatSnapshot.data?.name ?? '');
        return FutureBuilder<String>(
          future: resolvedChatNameFuture,
          builder: (context, nameSnapshot) {
            final resolvedChatName = nameSnapshot.data ?? '';
            if (chat is DirectChat) {
              return StreamBuilder(
                stream: this.context.appController.watchMessagesForDirectChat(
                  chat.id,
                ),
                builder: (context, msgSnapshot) {
                  if (msgSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(width: 32, child: AppLoader()),
                    );
                  } else if (msgSnapshot.hasError) {
                    return Center(
                      child: ErrorState(
                        message:
                            'Error loading messages!: ${msgSnapshot.error}',
                      ),
                    );
                  }
                  final messages = msgSnapshot.data;
                  final lastSenderId = messages?.isNotEmpty == true
                      ? messages!.first.senderId
                      : null;
                  final unreadCount = (chat as DirectChat).unreadCount;
                  final description = messages == null || messages.isEmpty
                      ? 'No messages yet'
                      : chat.lastMessage;
                  final control = canEdit
                      ? AppListItemControl.largeButton
                      : (lastSenderId != null &&
                            lastSenderId != user.id &&
                            unreadCount > 0)
                      ? AppListItemControl.badge
                      : AppListItemControl.none;
                  final symbol = canEdit
                      ? null
                      : (lastSenderId != null &&
                            lastSenderId != user.id &&
                            unreadCount > 0)
                      ? unreadCount.toString()
                      : null;
                  final largeButtonText = canEdit ? 'Delete' : null;
                  final onPressed = canEdit
                      ? () =>
                            this.context.appController.deleteDirectChat(chat.id)
                      : () async {
                          if (!mounted) return;
                          this.context.push('/chats/${chat.id}');
                          if (lastSenderId != null &&
                              lastSenderId != user.id &&
                              unreadCount > 0) {
                            await this.context.appController
                                .updateDirectChatUnreadCount(
                                  chatId: chat.id,
                                  unreadCount: 0,
                                );
                          }
                        };
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacing4),
                    child: SizedBox(
                      height: 72,
                      child: otherParticipantId.isEmpty
                          ? AppListItem(
                              title: resolvedChatName,
                              description: description,
                              avatar: AppAvatar.avatarOrPlaceholder(
                                null,
                                AvatarSize.small,
                              ),
                              control: control,
                              symbol: symbol,
                              largeButtonText: largeButtonText,
                              onPressed: onPressed,
                            )
                          : StreamBuilder(
                              stream: this.context.appController
                                  .watchUserWithId(otherParticipantId),
                              builder: (context, asyncSnapshot) {
                                final otherUser = asyncSnapshot.data;
                                return AppListItem(
                                  title: resolvedChatName,
                                  description: description,
                                  avatar: AppAvatar.avatarOrPlaceholder(
                                    otherUser,
                                    AvatarSize.small,
                                  ),
                                  control: control,
                                  symbol: symbol,
                                  largeButtonText: largeButtonText,
                                  onPressed: onPressed,
                                );
                              },
                            ),
                    ),
                  );
                },
              );
            } else if (chat is GroupChat) {
              return StreamBuilder(
                stream: this.context.appController.watchMessagesForGroupChat(
                  chat.id,
                ),
                builder: (context, msgSnapshot) {
                  if (msgSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(width: 32, child: AppLoader()),
                    );
                  } else if (msgSnapshot.hasError) {
                    return Center(
                      child: ErrorState(
                        message:
                            'Error loading messages!: ${msgSnapshot.error}',
                      ),
                    );
                  }
                  final messages = msgSnapshot.data;
                  final description = messages == null || messages.isEmpty
                      ? 'No messages yet'
                      : chat.lastMessage;
                  final largeButtonText = canEdit ? 'Delete' : null;
                  final onPressed = canEdit
                      ? () =>
                            this.context.appController.deleteGroupChat(chat.id)
                      : () {
                          if (!mounted) return;
                          this.context.push('/chats/${chat.id}');
                        };
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacing4),
                    child: SizedBox(
                      height: 72,
                      child: AppListItem(
                        title: resolvedChatName,
                        description: description,
                        avatar: AppAvatar.groupAvatarOrPlaceholder(
                          (chat as GroupChat),
                          AvatarSize.small,
                        ),
                        control: canEdit
                            ? AppListItemControl.largeButton
                            : AppListItemControl.none,
                        symbol: null,
                        largeButtonText: largeButtonText,
                        onPressed: onPressed,
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
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
