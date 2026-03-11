import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum ChatWizardMode { create, edit }

class ChatWizard extends StatefulWidget {
  final ChatWizardMode mode;
  final Chat? chatToEdit;

  const ChatWizard({
    super.key,
    this.mode = ChatWizardMode.create,
    this.chatToEdit,
  });

  static Future<Chat?> manageChat(
    BuildContext context, {
    ChatWizardMode mode = ChatWizardMode.create,
    Chat? chatToEdit,
  }) async {
    return await showDialog<Chat?>(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
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
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(spacing16),
        width: MediaQuery.sizeOf(context).width * 0.5,
        height: MediaQuery.sizeOf(context).height * 0.8,
        decoration: BoxDecoration(
          color: LightColor.lightest.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(spacing16),
            child: Column(
              spacing: spacing8,
              children: [
                AppListTitle(
                  title: widget.mode == ChatWizardMode.create
                      ? 'Create Chat'
                      : 'Edit Chat',
                ),
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
                              text: 'Add a member',
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
                                  final participantId =
                                      _participants.value[index];
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
                                                '@${participant.handle}',
                                            avatar:
                                                AppAvatar.avatarOrPlaceholder(
                                                  participant,
                                                  AvatarSize.small,
                                                ),
                                            control:
                                                _participants.value[index] ==
                                                    (context.appState.user
                                                            as AuthorizedUser)
                                                        .id
                                                ? AppListItemControl.none
                                                : AppListItemControl
                                                      .largeButton,
                                            largeButtonText:
                                                _participants.value[index] ==
                                                    (context.appState.user
                                                            as AuthorizedUser)
                                                        .id
                                                ? null
                                                : 'Remove',
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
                              _participants.value.length > 1)
                            AppTextField(
                              title: 'Chat name',
                              placeholder: 'Enter chat name',
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                            ),
                          if (widget.mode == ChatWizardMode.edit &&
                              _participants.value.length > 1)
                            const SizedBox(height: spacing16),
                          if (widget.mode == ChatWizardMode.edit &&
                              _participants.value.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppButtonPrimary(
                                  text: 'Pick an avatar',
                                  onPressed: () async {
                                    // TODO
                                  },
                                ),
                                StreamBuilder(
                                  stream: context.appController
                                      .watchGroupChatWithId(
                                        widget.chatToEdit!.id,
                                      ),
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
                    text: 'Save',
                    onPressed: () async {
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
                        final chat = await context.appController
                            .createGroupChat(
                              participants: participants,
                              chatName: chatName,
                            );
                        if (!context.mounted) return;
                        context.pop(chat);
                        return;
                      }
                      final chat = await context.appController.createDirectChat(
                        participants: participants,
                        chatName: chatName,
                      );
                      if (!context.mounted) return;
                      context.pop(chat);
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
