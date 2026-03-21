import 'package:flutter/material.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_calendar.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/project_wizard.dart';

class ProjectScreen extends StatelessWidget {
  final String projectId;

  const ProjectScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) => !previous.isFailed && current.isFailed,
      listener: (context, previous, current) {
        if (current.isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongColor,
              content: Text(
                '${context.l10n.errorLabel}: ${current.message}',
                style: TextStyle(
                  fontSize: cMSize,
                  fontWeight: cMWeight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(context),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing16),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return StreamBuilder(
      stream: context.appController.watchProjectWithId(projectId),
      builder: (context, snapshot) {
        final project = snapshot.data;
        if (project == null) {
          return AppNavBar(
            title: context.l10n.projectNotFoundLabel,
            leftIcon: AppIcons.arrowLeft,
            onPressedLeft: () => AppNavigator.of(context).pop(),
          );
        }
        return AppNavBar(
          title: project.name,
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () => AppNavigator.of(context).pop(),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: context.appController.watchProjectWithId(projectId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ErrorState(
              message:
                  '${context.l10n.errorLoadingProjectMessage}: ${snapshot.error}',
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: AppLoader());
        }
        final project = snapshot.data!;

        return ListView(
          children: [
            Text(
              project.name,
              style: TextStyle(
                fontSize: h1Size,
                fontWeight: h1Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            _buildOwnerRow(context, project),
            const SizedBox(height: spacing16),
            Text(
              '${context.l10n.statusLabel}: ${project.status.displayName(context)}',
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongColor,
              ),
            ),
            const SizedBox(height: spacing24),
            Text(
              context.l10n.descriptionLabel,
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            Text(
              project.description.isEmpty
                  ? context.l10n.noDescriptionProvidedLabel
                  : project.description,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundWeakColor,
              ),
            ),
            const SizedBox(height: spacing24),
            _buildParticipantsRow(context, project),
            const SizedBox(height: spacing8),
            _buildParticipantsList(context, project),
            const SizedBox(height: spacing24),
            Text(
              context.l10n.deadlineLabel,
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            const SizedBox(height: spacing8),
            _buildDeadlineCalendar(context, project),
            if (project.status == ProjectStatus.finished) ...[
              const SizedBox(height: spacing24),
              const AppDivider(),
              const SizedBox(height: spacing24),
              Text(
                context.l10n.projectCompletedLabel,
                style: TextStyle(
                  fontSize: h2Size,
                  fontWeight: h2Weight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
              const SizedBox(height: spacing16),
              AppButtonPrimary(
                text: context.l10n.provideFeedbackLabel,
                onPressed: () {
                  AppNavigator.of(
                    context,
                  ).push(ProjectFeedbackPage(projectId: projectId));
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOwnerRow(BuildContext context, Project project) {
    return StreamBuilder(
      stream: context.appController.watchUserWithId(project.ownerId),
      builder: (context, asyncSnapshot) {
        final owner = asyncSnapshot.data;
        if (owner == null) {
          return Text(
            context.l10n.createdByUnknownLabel,
            style: TextStyle(
              fontSize: bMSize,
              fontWeight: bMWeight,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundWeakColor,
            ),
          );
        }
        final user = context.appState.user as AuthorizedUser;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${context.l10n.createdByLabel(owner.handle.isEmpty ? owner.name : '@${owner.handle}')}\n'
              '${context.l10n.atLabel(project.createdAt.toLocal().toString().split('.').first)}\n'
              '${context.l10n.lastUpdatedAtLabel(project.lastUpdated.toLocal().toString().split('.').first)}',
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundWeakColor,
              ),
            ),
            AppButtonPrimary(
              text: 'Edit',
              onPressed: user.id == owner.id
                  ? () async {
                      final p = await ProjectWizard.manageProject(
                        context,
                        ProjectWizardMode.edit,
                        project,
                      );
                      if (p != null) {
                        // Handle the updated project
                      }
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticipantsRow(BuildContext context, Project project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${context.l10n.participantsLabel}:',
          style: TextStyle(
            fontSize: h3Size,
            fontWeight: h3Weight,
            color: Theme.of(
              context,
            ).extension<AppTheme>()?.foregroundStrongestColor,
          ),
        ),
        _buildChatButton(context, project),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, Project project) {
    return StreamBuilder(
      stream: context.chatController!.watchGroupChatsForUser(
        (context.appState.user as AuthorizedUser).id,
      ),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return ErrorState(
            message:
                '${context.l10n.errorLoadingChatsMessage}: ${asyncSnapshot.error}',
          );
        } else if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
          return AppButtonPrimary(
            text: context.l10n.chatLabel,
            onPressed: null,
          );
        }

        final chats = asyncSnapshot.data!;
        final doesGroupChatExistForProject = chats.any(
          (c) => c.id == project.groupChatId,
        );
        return AppButtonPrimary(
          text: doesGroupChatExistForProject || project.participants.length == 2
              ? context.l10n.chatLabel
              : context.l10n.createChatLabel,
          onPressed: _getChatButtonOnPressed(
            context,
            project,
            doesGroupChatExistForProject,
          ),
        );
      },
    );
  }

  VoidCallback? _getChatButtonOnPressed(
    BuildContext context,
    Project project,
    bool doesGroupChatExistForProject,
  ) {
    final user = context.appState.user as AuthorizedUser;
    final appController = context.appController;
    final chatController = context.chatController!;
    if (project.participants.length == 2) {
      return () {
        appController
            .watchAllUsers()
            .firstWhere((users) {
              if (users == null || users.isEmpty) return false;
              return users.any(
                (u) => project.participants.contains(u.id) && u.id != user.id,
              );
            })
            .then((users) async {
              if (users == null || users.isEmpty) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongColor,
                    content: Text(
                      context.l10n.noOtherParticipantsMessage,
                      style: TextStyle(
                        fontSize: cMSize,
                        fontWeight: cMWeight,
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongestColor,
                      ),
                    ),
                  ),
                );
                return;
              }
              final otherUser = users.firstWhere(
                (u) => project.participants.contains(u.id) && u.id != user.id,
              );
              final chat =
                  (await chatController
                          .watchDirectChatsForUser(user.id)
                          .firstWhere((chats) {
                            if (chats == null || chats.isEmpty) return false;
                            return chats.any(
                              (c) =>
                                  c.participants.length == 2 &&
                                  c.participants.contains(otherUser.id) &&
                                  c.participants.contains(user.id),
                            );
                          }))
                      ?.firstWhere(
                        (c) =>
                            c.participants.length == 2 &&
                            c.participants.contains(otherUser.id) &&
                            c.participants.contains(user.id),
                      );
              if (chat == null) {
                final participants = [otherUser.id, user.id];
                final participantNames = [otherUser.name, user.name];
                final newChat = await chatController.createDirectChat(
                  participants: participants,
                  chatName: participantNames.join(', '),
                );
                if (!context.mounted) return;
                AppNavigator.of(
                  context,
                ).push(ChatPage(chatId: newChat.id, chatType: ChatType.direct));
                return;
              }
              if (!context.mounted) return;
              AppNavigator.of(
                context,
              ).push(ChatPage(chatId: chat.id, chatType: ChatType.direct));
            });
      };
    } else if (project.participants.length > 2 &&
        project.ownerId != user.id &&
        doesGroupChatExistForProject) {
      return () {
        chatController.watchGroupChatsForUser(user.id).first.then((
          chats,
        ) async {
          Chat? matchingChat;
          if (project.groupChatId.isNotEmpty &&
              chats != null &&
              chats.any((c) => c.id == project.groupChatId)) {
            matchingChat = chats.firstWhere((c) => c.id == project.groupChatId);
          }
          if (matchingChat != null) {
            if (!context.mounted) return;
            AppNavigator.of(
              context,
            ).push(ChatPage(chatId: matchingChat.id, chatType: ChatType.group));
            return;
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongColor,
              content: Text(
                context.l10n.noGroupChatFoundMessage,
                style: TextStyle(
                  fontSize: cMSize,
                  fontWeight: cMWeight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
            ),
          );
        });
      };
    } else if (project.participants.length > 2 && project.ownerId == user.id) {
      return () {
        chatController.watchGroupChatsForUser(user.id).first.then((
          chats,
        ) async {
          Chat? matchingChat;
          if (project.groupChatId.isNotEmpty &&
              chats != null &&
              chats.any((c) => c.id == project.groupChatId)) {
            matchingChat = chats.firstWhere((c) => c.id == project.groupChatId);
          }
          if (matchingChat != null) {
            if (!context.mounted) return;
            AppNavigator.of(
              context,
            ).push(ChatPage(chatId: matchingChat.id, chatType: ChatType.group));
            return;
          }
          if (!context.mounted) return;
          final chat = await chatController.createGroupChat(
            chatName: '${context.l10n.projectTitle} "${project.name}"',
            participants: project.participants,
          );
          await appController.updateProject(
            project.copyWith(groupChatId: chat.id),
          );
          if (!context.mounted) return;
          AppNavigator.of(
            context,
          ).push(ChatPage(chatId: chat.id, chatType: ChatType.group));
        });
      };
    }
    return null;
  }

  Widget _buildParticipantsList(BuildContext context, Project project) {
    return StreamBuilder(
      stream: context.appController.watchProjectParticipants(project.id),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return Center(
            child: ErrorState(
              message:
                  '${context.l10n.errorLoadingParticipantsMessage}: ${asyncSnapshot.error}',
            ),
          );
        } else if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
          return const SizedBox.shrink();
        }

        final users = asyncSnapshot.data!;
        if (users.isEmpty) {
          return Center(
            child: ErrorState(message: context.l10n.noParticipantsFoundMessage),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing16,
          children: users.map((user) {
            return AppListItem(
              title: user.name,
              description: user.handle.isNotEmpty ? '@${user.handle}' : null,
              avatar: AppAvatar.avatarOrPlaceholder(user, AvatarSize.small),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDeadlineCalendar(BuildContext context, Project project) {
    return AppCalendarMonthly(
      initialDate: project.deadline,
      immutable: true,
      onDateSelected: (date) async {
        final updatedProject = project.copyWith(deadline: date);
        await context.appController.updateProject(updatedProject);
      },
    );
  }
}
