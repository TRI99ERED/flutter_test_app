import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum UserPickerMode {
  allUsers,
  friendsOnly,
  excludeFriends,
  excludeProjectParticipants,
}

enum UserPickerFlag {
  friendsOnly(1),
  excludeFriends(2),
  excludeProjectParticipants(4);

  final int value;
  const UserPickerFlag(this.value);
}

class UserPicker extends StatefulWidget {
  final List<AuthorizedUser> users;
  final int flags;
  final String? projectId;

  const UserPicker({
    super.key,
    required this.users,
    this.flags = 0,
    this.projectId,
  });

  static Future<AuthorizedUser?> pickUser(
    BuildContext context, [
    int flags = 0,
    String? projectId,
  ]) async {
    final userId = (context.appState.user as AuthorizedUser).id;

    if (!context.mounted) {
      return null;
    }
    final AppController appController = context.appController;
    List<AuthorizedUser>? users =
        (flags & UserPickerFlag.friendsOnly.value) != 0
        ? await appController.watchFriendsForUser(userId).first
        : await appController.watchAllUsers().first;

    if (!context.mounted) {
      return null;
    }

    if ((flags & UserPickerFlag.excludeFriends.value) != 0) {
      final friends = await appController.watchFriendsForUser(userId).first;
      final friendIds = friends?.map((f) => f.id).toSet();
      users = users
          ?.where((u) => !(friendIds?.contains(u.id) ?? false))
          .toList();
    }
    if ((flags & UserPickerFlag.excludeProjectParticipants.value) != 0 &&
        projectId != null) {
      if (!context.mounted) {
        return null;
      }

      final project = await appController.watchProjectWithId(projectId).first;
      final participantIds = project?.participants;
      users = users
          ?.where((u) => !(participantIds?.contains(u.id) ?? false))
          .toList();
    }

    if (!context.mounted) {
      return null;
    }

    return await showDialog<AuthorizedUser>(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) {
        return UserPicker(
          users: users ?? [],
          flags: flags,
          projectId: projectId,
        );
      },
    );
  }

  @override
  State<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  final _searchQuery = ValueNotifier<String>('');

  String get _title {
    if ((widget.flags & UserPickerFlag.friendsOnly.value) != 0) {
      return 'Select a friend';
    }
    return 'Select a user';
  }

  String get _errorLabel {
    if ((widget.flags & UserPickerFlag.friendsOnly.value) != 0) {
      return 'friends';
    }
    return 'users';
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.users
        .where(
          (user) => user.id != (context.appState.user as AuthorizedUser).id,
        )
        .toList();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(spacing32),
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.8,
        decoration: BoxDecoration(
          color: LightColor.lightest.color,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            spacing: spacing8,
            children: [
              AppListTitle(title: _title),
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
                    final filteredUsers = users.where((user) {
                      final query = _searchQuery.value.toLowerCase();
                      return user.name.toLowerCase().contains(query) ||
                          user.handle.toLowerCase().contains(query);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Text('No $_errorLabel match your search'),
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
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: AppButtonPrimary(
                  onPressed: () => context.pop(),
                  text: 'Cancel',
                ),
              ),
            ],
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
