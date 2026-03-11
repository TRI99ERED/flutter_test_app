import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_card.dart';
import 'package:test_app/src/widgets/common/app_content_switcher.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum FriendsSectionType { friends, incomingRequests, outgoingRequests }

class Friends extends StatefulWidget {
  final ValueNotifier<bool> editPressed;

  const Friends({super.key, required this.editPressed});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final _sectionIndex = ValueNotifier<int>(0);
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
        spacing: spacing8,
        children: [
          AppContentSwitcher(
            sectionCount: 3,
            sectionTitles: [
              'Friends',
              'Incoming requests',
              'Outgoing requests',
            ],
            selectedIndex: _sectionIndex.value,
            onSectionSelected: (value) {
              _sectionIndex.value = value;
            },
          ),
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
            child: ValueListenableBuilder(
              valueListenable: _sectionIndex,
              builder: (context, value, child) {
                return switch (value) {
                  0 => _FriendsSection(
                    sectionType: FriendsSectionType.friends,
                    searchQuery: _searchQuery,
                    editPressed: widget.editPressed,
                  ),
                  1 => _FriendsSection(
                    sectionType: FriendsSectionType.incomingRequests,
                    searchQuery: _searchQuery,
                    editPressed: widget.editPressed,
                  ),
                  2 => _FriendsSection(
                    sectionType: FriendsSectionType.outgoingRequests,
                    searchQuery: _searchQuery,
                    editPressed: widget.editPressed,
                  ),
                  _ => ErrorState(message: 'Invalid section index: $value'),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sectionIndex.dispose();
    _searchQuery.dispose();
    super.dispose();
  }
}

class _FriendsSection extends StatefulWidget {
  final FriendsSectionType _sectionType;
  final ValueNotifier<String> _searchQuery;
  final ValueNotifier<bool> _editPressed;

  const _FriendsSection({
    required FriendsSectionType sectionType,
    required ValueNotifier<String> searchQuery,
    required ValueNotifier<bool> editPressed,
  }) : _editPressed = editPressed,
       _searchQuery = searchQuery,
       _sectionType = sectionType;

  @override
  State<_FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<_FriendsSection> {
  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return const ErrorState(message: 'User not authorized');
    }

    return StreamBuilder(
      stream: switch (widget._sectionType) {
        FriendsSectionType.friends => context.appController.watchFriendsForUser(
          user.id,
        ),
        FriendsSectionType.incomingRequests =>
          context.appController.watchFriendIncomingRequestsForUser(user.id),
        FriendsSectionType.outgoingRequests =>
          context.appController.watchFriendOutgoingRequestsForUser(user.id),
      },
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 32, child: AppLoader()));
        } else if (snapshot.hasError) {
          return ErrorState(
            message:
                'Error loading ${switch (widget._sectionType) {
                  FriendsSectionType.friends => 'friends',
                  FriendsSectionType.incomingRequests => 'incoming requests',
                  FriendsSectionType.outgoingRequests => 'outgoing requests',
                }}: ${snapshot.error}',
          );
        }

        final friends = snapshot.data ?? const [];

        if (friends.isEmpty) {
          return EmptyState(
            title: 'Nothing here. For now.',
            body:
                'This is where your ${switch (widget._sectionType) {
                  FriendsSectionType.friends => 'friends',
                  FriendsSectionType.incomingRequests => 'incoming requests',
                  FriendsSectionType.outgoingRequests => 'outgoing requests',
                }} will appear.',
            buttonText:
                widget._sectionType == FriendsSectionType.friends ||
                    widget._sectionType == FriendsSectionType.outgoingRequests
                ? 'Send friend request'
                : null,
            onButtonPressed:
                widget._sectionType == FriendsSectionType.friends ||
                    widget._sectionType == FriendsSectionType.outgoingRequests
                ? () async {
                    final user = context.appState.user as AuthorizedUser;
                    final appController = context.appController;
                    final selectedUser = await UserPicker.pickUser(
                      context,
                      UserPickerFlag.excludeFriends.value,
                    );
                    if (selectedUser == null) return;

                    await appController.sendFriendRequest(
                      user.id,
                      selectedUser.id,
                    );
                  }
                : null,
          );
        }

        return ValueListenableBuilder(
          valueListenable: widget._searchQuery,
          builder: (context, query, child) {
            final q = query.trim().toLowerCase();

            final filteredFriends = q.isEmpty
                ? friends
                : friends.where((friend) {
                    return friend.name.toLowerCase().contains(q);
                  }).toList();

            if (filteredFriends.isEmpty) {
              return EmptyState(
                title:
                    'No ${switch (widget._sectionType) {
                      FriendsSectionType.friends => 'friends',
                      FriendsSectionType.incomingRequests => 'incoming requests',
                      FriendsSectionType.outgoingRequests => 'outgoing requests',
                    }} found.',
                body: 'Try adjusting your search query.',
              );
            }

            return ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];

                final stream = switch (widget._sectionType) {
                  FriendsSectionType.friends =>
                    context.appController.watchFriendsForUser(user.id),
                  FriendsSectionType.incomingRequests =>
                    context.appController.watchFriendIncomingRequestsForUser(
                      user.id,
                    ),
                  FriendsSectionType.outgoingRequests =>
                    context.appController.watchFriendOutgoingRequestsForUser(
                      user.id,
                    ),
                };

                return StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(width: 32, child: AppLoader());
                    } else if (snapshot.hasError) {
                      return ErrorState(
                        message:
                            'Error loading ${switch (widget._sectionType) {
                              FriendsSectionType.friends => 'friend',
                              FriendsSectionType.incomingRequests => 'incoming request',
                              FriendsSectionType.outgoingRequests => 'outgoing request',
                            }}: ${snapshot.error}',
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: spacing4),
                      child: SizedBox(
                        height: 72,
                        child: ValueListenableBuilder(
                          valueListenable: widget._editPressed,
                          builder: (context, editPressed, child) {
                            return AppCardSmall(
                              title: friend.name,
                              subtitle: '@${friend.handle}',
                              avatar: AppAvatar.avatarOrPlaceholder(
                                friend,
                                AvatarSize.small,
                              ),
                              onAvatarPressed: () {},
                              leftButtonText: switch (widget._sectionType) {
                                FriendsSectionType.incomingRequests =>
                                  'Decline',
                                _ => null,
                              },
                              rightButtonText: switch (widget._sectionType) {
                                FriendsSectionType.friends =>
                                  editPressed ? 'Remove' : 'Message',
                                FriendsSectionType.incomingRequests => 'Accept',
                                FriendsSectionType.outgoingRequests => 'Cancel',
                              },
                              onPressedLeft: switch (widget._sectionType) {
                                FriendsSectionType.incomingRequests =>
                                  () async {
                                    final appController = context.appController;
                                    await appController.declineFriendRequest(
                                      friendUserId: friend.id,
                                    );
                                  },
                                _ => null,
                              },
                              onPressedRight: switch (widget._sectionType) {
                                FriendsSectionType.friends =>
                                  editPressed
                                      ? () async {
                                          final appController =
                                              context.appController;
                                          await appController.removeFriend(
                                            friendUserId: friend.id,
                                          );
                                        }
                                      : () async {
                                          final user =
                                              context.appState.user
                                                  as AuthorizedUser;
                                          final appController =
                                              context.appController;

                                          if (!mounted) return;
                                          final chat = await appController
                                              .createDirectChat(
                                                participants: [
                                                  user.id,
                                                  friend.id,
                                                ],
                                                chatName: '',
                                              );

                                          if (!context.mounted) return;
                                          context.push(
                                            '/chats/direct/${chat.id}',
                                          );
                                        },
                                FriendsSectionType.incomingRequests =>
                                  () async {
                                    final appController = context.appController;
                                    await appController.acceptFriendRequest(
                                      friendUserId: friend.id,
                                    );
                                  },
                                FriendsSectionType.outgoingRequests =>
                                  () async {
                                    final appController = context.appController;
                                    await appController.cancelFriendRequest(
                                      friendUserId: friend.id,
                                    );
                                  },
                              },
                            );
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
    );
  }
}

class FriendsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> editPressed;

  const FriendsAppBar({super.key, required this.editPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<FriendsAppBar> createState() => _FriendsAppBarState();
}

class _FriendsAppBarState extends State<FriendsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: widget.editPressed,
        builder: (context, value, child) {
          return AppNavBar(
            title: 'Friends',
            leftText: widget.editPressed.value ? 'Done' : 'Edit',
            rightIcon: AppIcons.add,
            onPressedLeft: () {
              widget.editPressed.value = !widget.editPressed.value;
            },
            onPressedRight: () async {
              final user = context.appState.user as AuthorizedUser;
              final appController = context.appController;
              final selectedUser = await UserPicker.pickUser(
                context,
                UserPickerFlag.excludeFriends.value,
              );
              if (selectedUser == null) return;

              await appController.sendFriendRequest(user.id, selectedUser.id);
            },
          );
        },
      ),
    );
  }
}
