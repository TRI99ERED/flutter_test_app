import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/features/home_screen/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Chats extends StatefulWidget {
  final ValueNotifier<int> selectedTabIndex;

  const Chats({super.key, required this.selectedTabIndex});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final _searchQuery = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return Scaffold(body: const SizedBox.shrink());
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
                    title: 'No chats found.',
                    body: 'This is where your chats go.',
                    buttonText: 'Start a chat',
                    onButtonPressed: () async {
                      final user = context.appState.user as AuthorizedUser;
                      final appController = context.appController;
                      final selectedUser = await showUserPicker(context, true);
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

                return ValueListenableBuilder(
                  valueListenable: _searchQuery,
                  builder: (context, value, child) {
                    final q = value.trim().toLowerCase();

                    String otherName(Chat chat) {
                      final names = chat.participantNames.entries
                          .where((entry) => entry.key != user.id)
                          .map((entry) => entry.value.toString())
                          .toList();
                      return names.isNotEmpty ? names.first : 'Unknown';
                    }

                    final filteredChats = q.isEmpty
                        ? chats
                        : chats.where((chat) {
                            return otherName(chat).toLowerCase().contains(q);
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
                                child: SizedBox(width: 32, child: AppLoader()),
                              );
                            } else if (snapshot.hasError) {
                              return ErrorState(
                                message:
                                    'Error loading chat: ${snapshot.error}',
                              );
                            }

                            if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: spacing4,
                                ),
                                child: SizedBox(
                                  height: 72,
                                  child: AppListItem(
                                    title: otherName(chat),
                                    description: 'No messages yet',
                                    avatar: PlaceholderAvatar(
                                      size: AvatarSize.small,
                                    ),
                                    control: AppListItemControl.none,
                                    onPressed: () {
                                      context.push('/chats/${chat.id}');
                                    },
                                  ),
                                ),
                              );
                            }

                            final lastSenderId = snapshot.data?.first.senderId;

                            if (lastSenderId != null &&
                                lastSenderId != user.id &&
                                chat.unreadCount > 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: spacing4,
                                ),
                                child: SizedBox(
                                  height: 72,
                                  child: AppListItem(
                                    title: otherName(chat),
                                    description: chat.lastMessage,
                                    avatar: PlaceholderAvatar(
                                      size: AvatarSize.small,
                                    ),
                                    symbol: chat.unreadCount.toString(),
                                    control: AppListItemControl.badge,
                                    onPressed: () async {
                                      context.push('/chats/${chat.id}');

                                      if (mounted) {
                                        await context.appController
                                            .updateChatUnreadCount(
                                              chatId: chat.id,
                                              unreadCount: 0,
                                            );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: spacing4,
                              ),
                              child: SizedBox(
                                height: 72,
                                child: AppListItem(
                                  title: otherName(chat),
                                  description: chat.lastMessage,
                                  avatar: PlaceholderAvatar(
                                    size: AvatarSize.small,
                                  ),
                                  control: AppListItemControl.none,
                                  onPressed: () {
                                    context.push('/chats/${chat.id}');
                                  },
                                ),
                              ),
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
  const ChatsAppBar({super.key});

  @override
  State<ChatsAppBar> createState() => _ChatsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatsAppBarState extends State<ChatsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppNavBar(
        title: 'Chats',
        leftText: 'Edit',
        rightIcon: AppIcons.create,
        onPressedLeft: () {},
        onPressedRight: () async {
          final user = context.appState.user as AuthorizedUser;
          final appController = context.appController;
          final selectedUser = await showUserPicker(context, true);
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
      ),
    );
  }
}
