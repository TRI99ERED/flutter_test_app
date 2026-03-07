import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/app_tap_bar.dart';
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

  Future<AuthorizedUser?> _showUserPicker(
    BuildContext context,
    AuthorizedUser currentUser,
  ) async {
    return await showDialog<AuthorizedUser>(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) {
        final usersStream = context.appController.watchAllUsers();

        return Center(
          child: SizedBox(
            width: 200,
            height: 300,
            child: Container(
              padding: const EdgeInsets.all(spacing16),
              decoration: BoxDecoration(
                color: LightColor.lightest.color,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Center(
                child: Column(
                  children: [
                    AppListTitle(title: 'Select a user'),
                    Expanded(
                      child: StreamBuilder<List<AuthorizedUser>>(
                        stream: usersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error loading users: ${snapshot.error}',
                            );
                          }

                          final users = (snapshot.data ?? [])
                              .where((user) => user.id != currentUser.id)
                              .toList();
                          if (users.isEmpty) {
                            return const Text('No users found');
                          }

                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return AppListItem(
                                title: user.name,
                                description: '@${user.handle}',
                                onPressed: () => context.pop(user),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    AppButtonPrimary(
                      text: 'Cancel',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return Scaffold(body: const SizedBox.shrink());
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppNavBar(
            title: 'Chats',
            leftText: 'Edit',
            rightIcon: AppIcons.create,
            onPressedLeft: () {},
            onPressedRight: () async {
              final user = context.appState.user as AuthorizedUser;
              final selectedUser = await _showUserPicker(context, user);
              if (selectedUser == null) return;

              if (!mounted) return;
              final appController = context.appController;
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
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: widget.selectedTabIndex,
        builder: (context, value, child) {
          return AppTapBar(
            tabCount: 3,
            selectedIndex: value,
            tabTitles: ['Chats', 'Friends', 'Settings'],
            tabIcons: [AppIcons.chat, AppIcons.profile, AppIcons.settings],
            onTabSelected: (value) {
              widget.selectedTabIndex.value = value;
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: spacing8,
          vertical: spacing16,
        ),
        child: Column(
          children: [
            AppSearchBar(
              placeholder: 'Search',
              onChanged: (value) {
                _searchQuery.value = value;
              },
              onSubmitted: (value) {
                _searchQuery.value = value;
              },
            ),
            Expanded(
              child: StreamBuilder<List<Chat>>(
                stream: context.appController.watchChatsForUser(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(width: 32, child: AppLoader()),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading chats: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                          color: ErrorColor.dark.color,
                        ),
                      ),
                    );
                  }

                  final chats = snapshot.data ?? const [];

                  if (chats.isEmpty) {
                    return Center(
                      child: Text(
                        'No chats found',
                        style: TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                          color: DarkColor.darkest.color,
                        ),
                      ),
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
                        return Center(
                          child: Text(
                            'No chats found',
                            style: TextStyle(
                              fontSize: h4Size,
                              fontWeight: h4Weight,
                              color: DarkColor.darkest.color,
                            ),
                          ),
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
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: spacing4,
                                  ),
                                  child: Text(
                                    'Error loading chat: ${snapshot.error}',
                                    style: TextStyle(
                                      fontSize: h1Size,
                                      fontWeight: h1Weight,
                                      color: ErrorColor.dark.color,
                                    ),
                                  ),
                                );
                              }

                              final lastSenderId =
                                  snapshot.data?.first.senderId;

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
      ),
    );
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }
}
