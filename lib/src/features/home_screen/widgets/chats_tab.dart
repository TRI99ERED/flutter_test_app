import 'package:flutter/material.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/chat_wizard.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_dialog.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/features/themes/styles.dart';

class ChatsTab extends StatefulWidget {
  final ValueNotifier<bool> editPressed;

  const ChatsTab({super.key, required this.editPressed});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final _searchQuery = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;
    if (user is! AuthorizedUser) {
      return ErrorState(message: context.l10n.userNotAuthorizedMessage);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: spacing8,
        vertical: spacing16,
      ),
      child: Column(
        children: [
          StreamBuilder(
            stream: context.appController.watchUserWithId(user.id),
            builder: (context, asyncSnapshot) {
              final syncedUser = asyncSnapshot.data;
              return AppSearchBar(
                placeholder: context.l10n.searchLabel,
                recentSearches: syncedUser?.chatRecentSearches ?? [],
                onChanged: (value) => _searchQuery.value = value,
                onSubmitted: (value) async {
                  _searchQuery.value = value;
                  if (syncedUser == null) return;
                  if (value.trim().isEmpty) return;
                  final updatedSearches = [
                    value,
                    ...syncedUser.chatRecentSearches.where(
                      (entry) => entry != value,
                    ),
                  ];
                  await context.appController.updateUser(
                    syncedUser.copyWith(chatRecentSearches: updatedSearches),
                  );
                },
                onDelete: (value) async {
                  if (syncedUser == null) return;
                  final updatedSearches = syncedUser.chatRecentSearches
                      .where((entry) => entry != value)
                      .toList();
                  await context.appController.updateUser(
                    syncedUser.copyWith(chatRecentSearches: updatedSearches),
                  );
                },
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: context.chatController!.watchAllChatsForUser(user.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        '${context.l10n.errorLoadingChatsMessage}: ${snapshot.error}',
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: SizedBox(height: 72, child: AppLoader()),
                  );
                }
                final chats = snapshot.data ?? const [];
                if (chats.isEmpty) {
                  return EmptyState(
                    title: context.l10n.nothingHereForNowLabel,
                    body: context.l10n.thisIsWhereYourChatsGoLabel,
                    buttonText: context.l10n.startAChatLabel,
                    onButtonPressed: () async {
                      final chat = await ChatWizard.manageChat(context);
                      if (!context.mounted || chat == null) return;
                      if (chat is DirectChat) {
                        AppNavigator.of(context).push(
                          ChatPage(chatId: chat.id, chatType: ChatType.direct),
                        );
                        widget.editPressed.value = false;
                      } else if (chat is GroupChat) {
                        AppNavigator.of(context).push(
                          ChatPage(chatId: chat.id, chatType: ChatType.group),
                        );
                        widget.editPressed.value = false;
                      }
                    },
                  );
                }
                return ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (context, query, child) {
                    final q = query.trim().toLowerCase();
                    List<Chat> filteredChats = [];
                    for (final chat in chats) {
                      final name = chat.name.toLowerCase();
                      if (name.isEmpty) {
                        if (q.isEmpty) {
                          filteredChats.add(chat);
                        }
                      } else if (name.contains(q)) {
                        filteredChats.add(chat);
                      }
                    }
                    return _FilteredChatsList(
                      chats: filteredChats,
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: editPressed,
      builder: (context, canEdit, _) {
        final q = query.trim().toLowerCase();
        List<Chat> filteredChats = [];
        for (final chat in chats) {
          final name = chat.name.toLowerCase();
          if (name.isEmpty) {
            if (q.isEmpty) {
              filteredChats.add(chat);
            }
          } else if (name.contains(q)) {
            filteredChats.add(chat);
          }
        }
        if (filteredChats.isEmpty) {
          return EmptyState(
            title: context.l10n.noChatsFoundLabel,
            body: context.l10n.tryAdjustingYourSearchQueryLabel,
          );
        }
        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            if (chat is DirectChat) {
              return StreamBuilder(
                stream: context.chatController!.watchDirectChatWithId(chat.id),
                builder: (context, asyncSnapshot) {
                  final chat = asyncSnapshot.data;
                  if (chat == null) {
                    return const SizedBox.shrink();
                  }
                  return _ChatListItem(
                    key: ValueKey(chat.id),
                    chat: chat,
                    user: user,
                    canEdit: canEdit,
                    mounted: mounted,
                    context: this.context,
                    editPressed: editPressed,
                  );
                },
              );
            } else if (chat is GroupChat) {
              return StreamBuilder(
                stream: context.chatController!.watchGroupChatWithId(chat.id),
                builder: (context, asyncSnapshot) {
                  final chat = asyncSnapshot.data;
                  if (chat == null) {
                    return const SizedBox.shrink();
                  }
                  return _ChatListItem(
                    key: ValueKey(chat.id),
                    chat: chat,
                    user: user,
                    canEdit: canEdit,
                    mounted: mounted,
                    context: this.context,
                    editPressed: editPressed,
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

class _ChatListItem extends StatelessWidget {
  final Chat chat;
  final AuthorizedUser user;
  final bool canEdit;
  final bool mounted;
  final BuildContext context;
  final ValueNotifier<bool> editPressed;

  const _ChatListItem({
    super.key,
    required this.chat,
    required this.user,
    required this.canEdit,
    required this.mounted,
    required this.context,
    required this.editPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (chat is DirectChat) {
      return StreamBuilder(
        stream: context.chatController!.watchDirectChatWithId(chat.id),
        builder: (context, chatSnapshot) {
          final directChat = chatSnapshot.data;
          if (directChat == null) {
            return const SizedBox.shrink();
          }
          final participants = directChat.participants;
          final otherParticipantId = participants.firstWhere(
            (id) => id != user.id,
            orElse: () => '',
          );
          return StreamBuilder(
            stream: context.appController.watchUserWithId(otherParticipantId),
            builder: (context, ayncSnapshot) {
              if (ayncSnapshot.hasError) {
                return ErrorState(
                  message: '${context.l10n.errorLabel}: ${ayncSnapshot.error}',
                );
              } else if (!ayncSnapshot.hasData || ayncSnapshot.data == null) {
                return const Center(
                  child: SizedBox(height: 72, child: AppLoader()),
                );
              }
              final otherUser = ayncSnapshot.data!;
              final resolvedChatName = otherUser.name;
              return StreamBuilder(
                stream: context.chatController!.watchMessagesForDirectChat(
                  directChat.id,
                ),
                builder: (context, msgSnapshot) {
                  final messages = msgSnapshot.data;
                  final lastSenderId = messages?.isNotEmpty == true
                      ? messages!.first.senderId
                      : null;
                  final unreadCount = directChat.unreadCount;
                  final description = messages == null || messages.isEmpty
                      ? context.l10n.noMessagesYetLabel
                      : directChat.lastMessage;
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
                  final largeButtonText = canEdit
                      ? context.l10n.deleteLabel
                      : null;
                  final onPressed = canEdit
                      ? () => AppDialog2.show(
                          context: context,
                          title: context.l10n.deleteChatLabel,
                          description: context.l10n.deleteChatConfirmationLabel,
                          buttonText1: context.l10n.cancelLabel,
                          buttonText2: context.l10n.deleteLabel,
                          onPressed1: (context) => Navigator.of(context).pop(),
                          onPressed2: (context) async {
                            Navigator.of(context).pop();
                            await context.chatController!.deleteDirectChat(
                              directChat.id,
                            );
                          },
                        )
                      : () async {
                          if (!mounted) return;
                          AppNavigator.of(context).push(
                            ChatPage(
                              chatId: directChat.id,
                              chatType: ChatType.direct,
                            ),
                          );
                          editPressed.value = false;
                        };
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacing4),
                    child: SizedBox(
                      height: 72,
                      child: otherParticipantId.isEmpty
                          ? AppListItem(
                              title:
                                  '$resolvedChatName ${otherUser.isOnline ? '●' : ''}'
                                      .trim(),
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
                          : AppListItem(
                              title:
                                  '$resolvedChatName ${otherUser.isOnline ? '●' : ''}'
                                      .trim(),
                              description: description,
                              avatar: AppAvatar.avatarOrPlaceholder(
                                otherUser,
                                AvatarSize.small,
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
            },
          );
        },
      );
    } else if (chat is GroupChat) {
      return StreamBuilder(
        stream: context.chatController!.watchGroupChatWithId(chat.id),
        builder: (context, chatSnapshot) {
          final groupChat = chatSnapshot.data;
          if (groupChat == null) {
            return const SizedBox.shrink();
          }
          return StreamBuilder(
            stream: context.chatController!.watchMessagesForGroupChat(
              groupChat.id,
            ),
            builder: (context, msgSnapshot) {
              final messages = msgSnapshot.data;
              final lastSenderId = messages?.isNotEmpty == true
                  ? messages!.first.senderId
                  : null;
              final description = messages == null || messages.isEmpty
                  ? context.l10n.noMessagesYetLabel
                  : groupChat.lastMessage;
              final unreadCounts = groupChat.unreadCounts;
              final unreadCount = unreadCounts[user.id] ?? 0;
              final control = canEdit && groupChat.ownerId == user.id
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
              final largeButtonText = canEdit && groupChat.ownerId == user.id
                  ? context.l10n.deleteLabel
                  : null;
              final onPressed = canEdit && groupChat.ownerId == user.id
                  ? () => AppDialog2.show(
                      context: context,
                      title: context.l10n.deleteChatLabel,
                      description: context.l10n.deleteChatConfirmationLabel,
                      buttonText1: context.l10n.cancelLabel,
                      buttonText2: context.l10n.deleteLabel,
                      onPressed1: (context) => Navigator.of(context).pop(),
                      onPressed2: (context) async {
                        Navigator.of(context).pop();
                        await context.chatController!.deleteGroupChat(
                          groupChat.id,
                        );
                      },
                    )
                  : () async {
                      if (!mounted) return;
                      AppNavigator.of(context).push(
                        ChatPage(
                          chatId: groupChat.id,
                          chatType: ChatType.group,
                        ),
                      );
                      editPressed.value = false;
                    };
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: spacing4),
                child: SizedBox(
                  height: 72,
                  child: AppListItem(
                    title: groupChat.name,
                    description: description,
                    avatar: AppAvatar.groupAvatarOrPlaceholder(
                      groupChat,
                      AvatarSize.small,
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
        },
      );
    }
    return const SizedBox.shrink();
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
            title: context.l10n.chatsTitle,
            leftText: widget.editPressed.value
                ? context.l10n.doneLabel
                : context.l10n.editLabel,
            rightIcon: AppIcons.create,
            onPressedLeft: () {
              widget.editPressed.value = !widget.editPressed.value;
            },
            onPressedRight: () async {
              final chat = await ChatWizard.manageChat(context);
              if (chat == null) return;

              if (context.mounted) {
                if (chat is DirectChat) {
                  AppNavigator.of(
                    context,
                  ).push(ChatPage(chatId: chat.id, chatType: ChatType.direct));
                  widget.editPressed.value = false;
                } else if (chat is GroupChat) {
                  AppNavigator.of(
                    context,
                  ).push(ChatPage(chatId: chat.id, chatType: ChatType.group));
                  widget.editPressed.value = false;
                }
              }
            },
          );
        },
      ),
    );
  }
}
