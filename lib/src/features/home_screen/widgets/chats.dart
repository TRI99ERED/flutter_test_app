import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
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

        return AlertDialog(
          title: const Text('Select User'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<AuthorizedUser>>(
              stream: usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading users: ${snapshot.error}');
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
                    return ListTile(
                      title: Text(user.name),
                      onTap: () => context.pop(user),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppNavBar(
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

                          return SizedBox(
                            height: 72,
                            child: AppListItem(
                              title: otherName(chat),
                              description: chat.lastMessage,
                              avatar: PlaceholderAvatar(size: AvatarSize.small),
                              onPressed: () {
                                context.push('/chats/${chat.id}');
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
