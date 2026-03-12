import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
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
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        return false;
      },
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
          child: SafeArea(
            child: StreamBuilder(
              stream: context.appController.watchProjectWithId(projectId),
              builder: (context, snapshot) {
                final project = snapshot.data;

                if (project == null) {
                  return AppNavBar(
                    title: 'Project not found',
                    leftIcon: AppIcons.arrowLeft,
                    onPressedLeft: () {
                      context.pop();
                    },
                  );
                }

                return AppNavBar(
                  title: project.name,
                  leftIcon: AppIcons.arrowLeft,
                  onPressedLeft: () {
                    context.pop();
                  },
                );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing16),
            child: StreamBuilder(
              stream: context.appController.watchProjectWithId(projectId),
              builder: (context, snapshot) {
                final project = snapshot.data;

                if (project == null) {
                  return ErrorState(
                    message: 'Project with id $projectId not found',
                  );
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
                    StreamBuilder(
                      stream: context.appController.watchUserWithId(
                        project.ownerId,
                      ),
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
                              'Created by @${owner.handle} at ${project.createdAt.toLocal().toString().split('.').first}.\nLast updated at ${project.lastUpdated.toLocal().toString().split('.').first}',
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
                                      final p =
                                          await ProjectWizard.manageProject(
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
                    ),
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
                    Row(
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
                        AppButtonPrimary(
                          text: 'Chat',
                          onPressed: () {
                            // TODO
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing8),
                    StreamBuilder(
                      stream: context.appController.watchProjectParticipants(
                        project.id,
                      ),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: AppLoader());
                        }
                        if (asyncSnapshot.hasError) {
                          return Center(
                            child: ErrorState(
                              message:
                                  'Error loading participants: ${asyncSnapshot.error}',
                            ),
                          );
                        }
                        final users = asyncSnapshot.data ?? [];

                        if (users.isEmpty) {
                          return const Center(
                            child: ErrorState(
                              message: 'No participants found.',
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: spacing16,
                          children: users.map((user) {
                            return AppListItem(
                              title: user.name,
                              description: '@${user.handle}',
                              avatar: AppAvatar.avatarOrPlaceholder(
                                user,
                                AvatarSize.small,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
