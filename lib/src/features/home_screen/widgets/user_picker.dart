import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum UserPickerMode { allUsers, friendsOnly, excludeFriends }

Future<AuthorizedUser?> showUserPicker(
  BuildContext context, [
  UserPickerMode mode = UserPickerMode.allUsers,
]) async {
  return await showDialog<AuthorizedUser>(
    context: context,
    barrierColor: Colors.black.withAlpha(216),
    builder: (context) {
      final usersStream = switch (mode) {
        UserPickerMode.friendsOnly => context.appController.watchFriendsForUser(
          (context.appState.user as AuthorizedUser).id,
        ),
        UserPickerMode.allUsers => context.appController.watchAllUsers(),
        UserPickerMode.excludeFriends =>
          context.appController.watchAllUsersExcludingFriends(
            (context.appState.user as AuthorizedUser).id,
          ),
      };

      return UserPicker(usersStream: usersStream, mode: mode);
    },
  );
}

class UserPicker extends StatefulWidget {
  final Stream<List<AuthorizedUser>> usersStream;
  final UserPickerMode mode;

  const UserPicker({
    super.key,
    required this.usersStream,
    this.mode = UserPickerMode.allUsers,
  });

  @override
  State<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  final _searchQuery = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.5,
        height: MediaQuery.sizeOf(context).width * 0.8,
        child: Container(
          padding: const EdgeInsets.all(spacing16),
          decoration: BoxDecoration(
            color: LightColor.lightest.color,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                spacing: spacing8,
                children: [
                  AppListTitle(
                    title:
                        'Select a ${switch (widget.mode) {
                          UserPickerMode.friendsOnly => 'friend',
                          _ => 'user',
                        }}',
                  ),
                  AppSearchBar(
                    onChanged: (value) {
                      _searchQuery.value = value;
                    },
                    onSubmitted: (value) {
                      _searchQuery.value = value;
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _searchQuery,
                      builder: (context, value, child) {
                        return StreamBuilder(
                          stream: widget.usersStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error loading ${switch (widget.mode) {
                                  UserPickerMode.friendsOnly => 'friends',
                                  _ => 'users',
                                }}: ${snapshot.error}',
                              );
                            }
                            final users = (snapshot.data ?? [])
                                .where(
                                  (user) =>
                                      user.id !=
                                      (context.appState.user as AuthorizedUser)
                                          .id,
                                )
                                .toList();

                            if (users.isEmpty) {
                              return Center(
                                child: Text(
                                  'No ${switch (widget.mode) {
                                    UserPickerMode.friendsOnly => 'friends',
                                    _ => 'users',
                                  }} found',
                                ),
                              );
                            }

                            final filteredUsers = users.where((user) {
                              final query = _searchQuery.value.toLowerCase();
                              return user.name.toLowerCase().contains(query) ||
                                  user.handle.toLowerCase().contains(query);
                            }).toList();

                            if (filteredUsers.isEmpty) {
                              return Center(
                                child: Text(
                                  'No ${switch (widget.mode) {
                                    UserPickerMode.friendsOnly => 'friends',
                                    _ => 'users',
                                  }} match your search',
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return AppListItem(
                                  title: user.name,
                                  description: '@${user.handle}',
                                  onPressed: () => context.pop(user),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  AppButtonPrimary(
                    onPressed: () => context.pop(),
                    text: 'Cancel',
                  ),
                ],
              ),
            ),
          ),
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
