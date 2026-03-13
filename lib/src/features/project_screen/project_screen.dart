import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/styles.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SafeArea(child: _buildAppBar(context)),
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
            title: 'Project not found',
            leftIcon: AppIcons.arrowLeft,
            onPressedLeft: () => context.pop(),
          );
        }
        return AppNavBar(
          title: project.name,
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () => context.pop(),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder(
      stream: context.appController.watchProjectWithId(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoader());
        } else if (snapshot.hasError) {
          return Center(
            child: ErrorState(
              message: 'Error loading project: ${snapshot.error}',
            ),
          );
        }
        final project = snapshot.data;
        if (project == null) {
          return ErrorState(message: 'Project with id $projectId not found');
        }
        return ListView(
          children: [
            Text(
              project.name,
              style: TextStyle(
                fontSize: h1Size,
                fontWeight: h1Weight,
                color: DarkColor.darkest.color,
              ),
            ),
            _buildOwnerRow(context, project),
            const SizedBox(height: spacing16),
            Text(
              'Status: ${project.status.displayName}',
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: DarkColor.dark.color,
              ),
            ),
            const SizedBox(height: spacing24),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: DarkColor.darkest.color,
              ),
            ),
            Text(
              project.description.isEmpty
                  ? 'No description provided.'
                  : project.description,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: DarkColor.light.color,
              ),
            ),
            const SizedBox(height: spacing24),
            _buildParticipantsRow(context, project),
            const SizedBox(height: spacing8),
            _buildParticipantsList(context, project),
            if (project.status == ProjectStatus.finished) ...[
              const SizedBox(height: spacing24),
              const AppDivider(),
              const SizedBox(height: spacing24),
              Text(
                'Project completed! Please provide your feedback.',
                style: TextStyle(
                  fontSize: h2Size,
                  fontWeight: h2Weight,
                  color: DarkColor.darkest.color,
                ),
              ),
              const SizedBox(height: spacing16),
              AppButtonPrimary(
                text: 'Provide Feedback',
                onPressed: () {
                  context.push('/projects/$projectId/feedback');
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
          return Text('Created by unknown');
        }
        final user = context.appState.user as AuthorizedUser;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Created by @${owner.handle}\n'
              'at ${project.createdAt.toLocal().toString().split('.').first}\n'
              'Last updated at ${project.lastUpdated.toLocal().toString().split('.').first}',
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: DarkColor.light.color,
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
          'Participants:',
          style: TextStyle(
            fontSize: h3Size,
            fontWeight: h3Weight,
            color: DarkColor.darkest.color,
          ),
        ),
        _buildChatButton(context, project),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, Project project) {
    return StreamBuilder(
      stream: context.appController.watchGroupChatsForUser(
        (context.appState.user as AuthorizedUser).id,
      ),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader();
        } else if (asyncSnapshot.hasError) {
          return ErrorState(
            message: 'Error loading chats: ${asyncSnapshot.error}',
          );
        }
        final chats = asyncSnapshot.data ?? [];
        final doesGroupChatExistForProject = chats.any(
          (c) => c.id == project.groupChatId,
        );
        return AppButtonPrimary(
          text: 'Chat',
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
    if (project.participants.length == 2) {
      return () {
        context.appController
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
                  const SnackBar(
                    content: Text('No other participants found for chat.'),
                  ),
                );
                return;
              }
              final otherUser = users.firstWhere(
                (u) => project.participants.contains(u.id) && u.id != user.id,
              );
              if (!context.mounted) return;
              final chat =
                  (await context.appController
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
                if (!context.mounted) return;
                final participants = [otherUser.id, user.id];
                final participantNames = [otherUser.name, user.name];
                final newChat = await context.appController.createDirectChat(
                  participants: participants,
                  chatName: participantNames.join(', '),
                );
                if (!context.mounted) return;
                context.push('/chats/direct/${newChat.id}');
                return;
              }
              if (!context.mounted) return;
              context.push('/chats/direct/${chat.id}');
            });
      };
    } else if (project.participants.length > 2 &&
        project.ownerId != user.id &&
        doesGroupChatExistForProject) {
      return () {
        context.appController.watchGroupChatsForUser(user.id).first.then((
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
            context.push('/chats/group/${matchingChat.id}');
            return;
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No group chat found for this project. Please ask the project owner to create one.',
              ),
            ),
          );
        });
      };
    } else if (project.participants.length > 2 && project.ownerId == user.id) {
      return () {
        context.appController.watchGroupChatsForUser(user.id).first.then((
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
            context.push('/chats/group/${matchingChat.id}');
            return;
          }
          if (!context.mounted) return;
          final chat = await context.appController.createGroupChat(
            chatName: 'Project "${project.name}"',
            participants: project.participants,
          );
          if (!context.mounted) return;
          context.push('/chats/group/${chat.id}');
          await context.appController.updateProject(
            project.copyWith(groupChatId: chat.id),
          );
        });
      };
    }
    return null;
  }

  Widget _buildParticipantsList(BuildContext context, Project project) {
    return StreamBuilder(
      stream: context.appController.watchProjectParticipants(project.id),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoader());
        }
        if (asyncSnapshot.hasError) {
          return Center(
            child: ErrorState(
              message: 'Error loading participants: ${asyncSnapshot.error}',
            ),
          );
        }
        final users = asyncSnapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(
            child: ErrorState(message: 'No participants found.'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing16,
          children: users.map((user) {
            return AppListItem(
              title: user.name,
              description: '@${user.handle}',
              avatar: AppAvatar.avatarOrPlaceholder(user, AvatarSize.small),
            );
          }).toList(),
        );
      },
    );
  }
}
