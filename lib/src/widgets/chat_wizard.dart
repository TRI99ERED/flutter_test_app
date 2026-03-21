import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/features/themes/styles.dart';

enum ChatWizardMode { create, edit }

class ChatWizard extends StatefulWidget {
  final ChatWizardMode mode;
  final Chat? chatToEdit;

  const ChatWizard({
    super.key,
    this.mode = ChatWizardMode.create,
    this.chatToEdit,
  }) : assert(
         mode == ChatWizardMode.create || chatToEdit != null,
         'chatToEdit must be provided when mode is edit',
       ),
       assert(
         chatToEdit == null || mode == ChatWizardMode.edit,
         'mode must be edit when chatToEdit is provided',
       ),
       assert(
         chatToEdit is GroupChat || mode == ChatWizardMode.create,
         'Only group chats can be edited',
       );

  static Future<Chat?> manageChat(
    BuildContext context, {
    ChatWizardMode mode = ChatWizardMode.create,
    Chat? chatToEdit,
  }) async {
    return await showDialog<Chat?>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ChatWizard(mode: mode, chatToEdit: chatToEdit),
    );
  }

  @override
  State<ChatWizard> createState() => _ChatWizardState();
}

class _ChatWizardState extends State<ChatWizard> {
  final _participants = ValueNotifier<List<String>>([]);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == ChatWizardMode.edit && widget.chatToEdit != null) {
        _nameController.text = widget.chatToEdit!.name;
        _participants.value = List<String>.from(
          widget.chatToEdit!.participants,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: switch (widget.mode) {
          ChatWizardMode.create => context.l10n.createAChatTitle,
          ChatWizardMode.edit => context.l10n.editChatTitle,
        },
        leftText: context.l10n.cancelLabel,
        onPressedLeft: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          spacing: spacing8,
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButtonPrimary(
                          text: context.l10n.addAParticipantLabel,
                          onPressed: () {
                            UserPicker.pickUser(
                              context,
                              UserPickerFlag.friendsOnly.value,
                            ).then((selectedUser) {
                              if (selectedUser != null &&
                                  !_participants.value.contains(
                                    selectedUser.id,
                                  )) {
                                _participants.value = [
                                  ..._participants.value,
                                  selectedUser.id,
                                ];
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: spacing16),
                      ValueListenableBuilder(
                        valueListenable: _participants,
                        builder: (context, value, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _participants.value.length,
                            itemBuilder: (context, index) {
                              final participantId = _participants.value[index];
                              return Column(
                                children: [
                                  StreamBuilder(
                                    stream: context.appController
                                        .watchUserWithId(participantId),
                                    builder: (context, snapshot) {
                                      final participant = snapshot.data;
                                      if (participant == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return AppListItem(
                                        title: participant.name,
                                        description:
                                            participant.handle.isNotEmpty
                                            ? '@${participant.handle}'
                                            : null,
                                        avatar: AppAvatar.avatarOrPlaceholder(
                                          participant,
                                          AvatarSize.small,
                                        ),
                                        control:
                                            _participants.value[index] ==
                                                (context.appState.user
                                                        as AuthorizedUser)
                                                    .id
                                            ? AppListItemControl.none
                                            : AppListItemControl.largeButton,
                                        largeButtonText:
                                            _participants.value[index] ==
                                                (context.appState.user
                                                        as AuthorizedUser)
                                                    .id
                                            ? null
                                            : context.l10n.removeLabel,
                                        onPressed:
                                            _participants.value[index] ==
                                                (context.appState.user
                                                        as AuthorizedUser)
                                                    .id
                                            ? null
                                            : () {
                                                _participants.value = [
                                                  ..._participants.value
                                                    ..removeAt(index),
                                                ];
                                              },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: spacing16),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      if (widget.mode == ChatWizardMode.edit &&
                          widget.chatToEdit! is GroupChat)
                        AppTextField(
                          title: context.l10n.chatNameLabel,
                          placeholder: context.l10n.enterChatNameLabel,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                        ),
                      if (widget.mode == ChatWizardMode.edit &&
                          widget.chatToEdit! is GroupChat)
                        const SizedBox(height: spacing16),
                      if (widget.mode == ChatWizardMode.edit &&
                          widget.chatToEdit! is GroupChat)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButtonPrimary(
                              text: context.l10n.pickAnAvatarLabel,
                              onPressed: () async {
                                await context.appController
                                    .uploadGroupChatAvatar(
                                      widget.chatToEdit!.id,
                                    );
                              },
                            ),
                            StreamBuilder(
                              stream: context.appController
                                  .watchGroupChatWithId(widget.chatToEdit!.id),
                              builder: (context, asyncSnapshot) {
                                final chat = asyncSnapshot.data;
                                if (chat == null) {
                                  return const SizedBox.shrink();
                                }
                                return AppAvatar.groupAvatarOrPlaceholder(
                                  chat,
                                  AvatarSize.large,
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                text: context.l10n.saveLabel,
                onPressed: switch (widget.mode) {
                  ChatWizardMode.create => () async {
                    final user = context.appState.user as AuthorizedUser;
                    final participants = {
                      user.id,
                      ..._participants.value,
                    }.toList();
                    String chatName;
                    if (_nameController.text.isNotEmpty) {
                      chatName = _nameController.text;
                    } else {
                      final names = await Future.wait(
                        participants.map(
                          (id) =>
                              context.appController.watchUserWithId(id).first,
                        ),
                      );
                      chatName = names
                          .whereType<AuthorizedUser>()
                          .map((user) => user.name)
                          .join(', ');
                    }
                    if (!context.mounted) return;

                    if (participants.length > 2) {
                      final chat = await context.appController.createGroupChat(
                        participants: participants,
                        chatName: chatName,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop(chat);
                      return;
                    }
                    if (participants.length == 2) {
                      final existingChat = await context.appController
                          .watchDirectChatsForUser(user.id)
                          .first
                          .then((chats) {
                            if (chats == null) {
                              return null;
                            }
                            return chats.firstWhere(
                              (c) => c.participants.contains(
                                participants.firstWhere((id) => id != user.id),
                              ),
                              orElse: () => DirectChat(
                                id: '',
                                name: '',
                                participants: [],
                                lastMessage: '',
                                lastUpdated: DateTime.now(),
                                unreadCount: 0,
                              ),
                            );
                          });
                      if (existingChat != null &&
                          existingChat.id.isNotEmpty &&
                          context.mounted) {
                        Navigator.of(context).pop(existingChat);
                        return;
                      }
                      if (!context.mounted) return;
                      final chat = await context.appController.createDirectChat(
                        participants: participants,
                        chatName: chatName,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop(chat);
                    }
                  },
                  ChatWizardMode.edit => () async {
                    if (widget.chatToEdit == null) return;
                    final chat = widget.chatToEdit!;
                    if (chat is GroupChat) {
                      final newGroupChat = chat.copyWith(
                        name: _nameController.text.isNotEmpty
                            ? _nameController.text
                            : chat.name,
                        participants: _participants.value,
                        avatarUrl: await context.appController
                            .watchGroupChatWithId(chat.id)
                            .first
                            .then((chat) => chat?.avatarUrl),
                        lastUpdated: DateTime.now(),
                      );
                      if (!context.mounted) return;
                      await context.appController.updateGroupChat(newGroupChat);
                      if (!context.mounted) return;
                      Navigator.of(context).pop(newGroupChat);
                    } else {
                      Navigator.of(context).pop(chat);
                    }
                  },
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                onPressed: () => Navigator.of(context).pop(),
                text: context.l10n.cancelLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _participants.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
