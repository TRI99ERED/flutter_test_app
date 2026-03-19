import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/main.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
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
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/user_profile.dart';

enum FriendsSectionType { friends, incomingRequests, outgoingRequests }

class Friends extends StatefulWidget {
  final int initialSection;
  final ValueNotifier<bool> editPressed;

  const Friends({
    super.key,
    this.initialSection = 0,
    required this.editPressed,
  });

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  late final _sectionIndex = ValueNotifier<int>(widget.initialSection);
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
              context.l10n.friendsTitle,
              context.l10n.incomingTitle,
              context.l10n.outgoingTitle,
            ],
            selectedIndex: _sectionIndex.value,
            onSectionSelected: (value) {
              _sectionIndex.value = value;
            },
          ),
          StreamBuilder(
            stream: context.appController.watchUserWithId(user.id),
            builder: (context, asyncSnapshot) {
              final syncedUser = asyncSnapshot.data;
              return AppSearchBar(
                placeholder: context.l10n.searchLabel,
                recentSearches: syncedUser?.friendRecentSearches ?? [],
                onChanged: (value) => _searchQuery.value = value,
                onSubmitted: (value) async {
                  _searchQuery.value = value;
                  if (syncedUser == null) return;
                  if (value.trim().isEmpty) return;
                  final updatedSearches = [
                    value,
                    ...syncedUser.friendRecentSearches.where(
                      (entry) => entry != value,
                    ),
                  ];
                  await context.appController.updateUser(
                    syncedUser.copyWith(friendRecentSearches: updatedSearches)
                        as AuthorizedUser,
                  );
                },
                onDelete: (value) async {
                  if (syncedUser == null) return;
                  final updatedSearches = syncedUser.friendRecentSearches
                      .where((entry) => entry != value)
                      .toList();
                  await context.appController.updateUser(
                    syncedUser.copyWith(friendRecentSearches: updatedSearches)
                        as AuthorizedUser,
                  );
                },
              );
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
                  _ => ErrorState(
                    message:
                        '${context.l10n.invalidSectionIndexMessage}: $value',
                  ),
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
      return ErrorState(message: context.l10n.userNotAuthorizedMessage);
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
          return const Center(child: SizedBox(height: 72, child: AppLoader()));
        } else if (snapshot.hasError) {
          return ErrorState(
            message:
                '${switch (widget._sectionType) {
                  FriendsSectionType.friends => context.l10n.errorLoadingFriendsMessage,
                  FriendsSectionType.incomingRequests => context.l10n.errorLoadingIncomingRequestsMessage,
                  FriendsSectionType.outgoingRequests => context.l10n.errorLoadingOutgoingRequestsMessage,
                }}: ${snapshot.error}',
          );
        }

        final friends = snapshot.data ?? const [];

        if (friends.isEmpty) {
          return EmptyState(
            title: context.l10n.nothingHereForNowLabel,
            body: switch (widget._sectionType) {
              FriendsSectionType.friends =>
                context.l10n.thisIsWhereYourFriendsWillAppearLabel,
              FriendsSectionType.incomingRequests =>
                context.l10n.thisIsWhereYourIncomingRequestsWillAppearLabel,
              FriendsSectionType.outgoingRequests =>
                context.l10n.thisIsWhereYourOutgoingRequestsWillAppearLabel,
            },
            buttonText:
                widget._sectionType == FriendsSectionType.friends ||
                    widget._sectionType == FriendsSectionType.outgoingRequests
                ? context.l10n.sendFriendRequestLabel
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
                title: switch (widget._sectionType) {
                  FriendsSectionType.friends =>
                    context.l10n.noFriendsFoundLabel,
                  FriendsSectionType.incomingRequests =>
                    context.l10n.noIncomingRequestsFoundLabel,
                  FriendsSectionType.outgoingRequests =>
                    context.l10n.noOutgoingRequestsFoundLabel,
                },
                body: context.l10n.tryAdjustingYourSearchQueryLabel,
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
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return ErrorState(
                        message:
                            '${switch (widget._sectionType) {
                              FriendsSectionType.friends => context.l10n.errorLoadingFriend,
                              FriendsSectionType.incomingRequests => context.l10n.errorLoadingIncomingRequest,
                              FriendsSectionType.outgoingRequests => context.l10n.errorLoadingOutgoingRequest,
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
                              subtitle: friend.handle.isNotEmpty
                                  ? '@${friend.handle}'
                                  : null,
                              avatar: AppAvatar.avatarOrPlaceholder(
                                friend,
                                AvatarSize.small,
                              ),
                              onAvatarPressed: () {
                                UserProfile.show(
                                  context,
                                  friend,
                                  mode: UserProfileMode.view,
                                );
                              },
                              leftButtonText: switch (widget._sectionType) {
                                FriendsSectionType.incomingRequests =>
                                  context.l10n.declineLabel,
                                _ => null,
                              },
                              rightButtonText: switch (widget._sectionType) {
                                FriendsSectionType.friends =>
                                  editPressed
                                      ? context.l10n.removeLabel
                                      : context.l10n.messageLabel,
                                FriendsSectionType.incomingRequests =>
                                  context.l10n.acceptLabel,
                                FriendsSectionType.outgoingRequests =>
                                  context.l10n.cancelLabel,
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
                                          final existingChat =
                                              await appController
                                                  .watchDirectChatsForUser(
                                                    user.id,
                                                  )
                                                  .first
                                                  .then((chats) {
                                                    if (chats == null) {
                                                      return null;
                                                    }
                                                    return chats.firstWhere(
                                                      (c) => c.participants
                                                          .contains(friend.id),
                                                      orElse: () => DirectChat(
                                                        id: '',
                                                        name: '',
                                                        participants: [],
                                                        lastMessage: '',
                                                        lastUpdated:
                                                            DateTime.now(),
                                                        unreadCount: 0,
                                                      ),
                                                    );
                                                  });
                                          if (existingChat != null &&
                                              existingChat.id.isNotEmpty) {
                                            rootNavigatorKey.currentContext?.push(
                                              '/chats/direct/${existingChat.id}',
                                            );
                                            return;
                                          }

                                          if (!context.mounted) return;
                                          final chat = await appController
                                              .createDirectChat(
                                                participants: [
                                                  user.id,
                                                  friend.id,
                                                ],
                                                chatName:
                                                    '${(context.appState.user as AuthorizedUser).name}, ${friend.name}',
                                              );

                                          rootNavigatorKey.currentContext?.push(
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
            title: context.l10n.friendsTitle,
            leftText: widget.editPressed.value
                ? context.l10n.doneLabel
                : context.l10n.editLabel,
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
