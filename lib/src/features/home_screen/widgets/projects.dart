import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/project_wizard.dart';
import 'package:test_app/src/widgets/common/app_content_switcher.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Projects extends StatefulWidget {
  final ValueNotifier<bool> editPressed;

  const Projects({super.key, required this.editPressed});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  final _sectionIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
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
              ProjectStatus.todo.displayName,
              ProjectStatus.inProgress.displayName,
              ProjectStatus.finished.displayName,
            ],
            selectedIndex: _sectionIndex.value,
            onSectionSelected: (value) {
              _sectionIndex.value = value;
            },
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _sectionIndex,
              builder: (context, value, child) {
                return switch (value) {
                  0 => _ProjectsSection(
                    sectionType: ProjectStatus.todo,
                    editPressed: widget.editPressed,
                  ),
                  1 => _ProjectsSection(
                    sectionType: ProjectStatus.inProgress,
                    editPressed: widget.editPressed,
                  ),
                  2 => _ProjectsSection(
                    sectionType: ProjectStatus.finished,
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
    super.dispose();
  }
}

class _ProjectsSection extends StatefulWidget {
  final ProjectStatus _sectionType;
  final ValueNotifier<bool> _editPressed;

  const _ProjectsSection({
    required ProjectStatus sectionType,
    required ValueNotifier<bool> editPressed,
  }) : _sectionType = sectionType,
       _editPressed = editPressed;

  @override
  State<_ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<_ProjectsSection> {
  late final ValueNotifier<String> _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = ValueNotifier<String>('');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;

    if (user is! AuthorizedUser) {
      return const ErrorState(message: 'User not authorized');
    }

    return Column(
      children: [
        AppSearchBar(
          onChanged: (value) {
            _searchQuery.value = value;
          },
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _searchQuery,
            builder: (context, value, child) {
              return StreamBuilder(
                stream: switch (widget._sectionType) {
                  ProjectStatus.todo =>
                    context.appController.watchToDoProjectsForUser(user.id),
                  ProjectStatus.inProgress =>
                    context.appController.watchInProgressProjectsForUser(
                      user.id,
                    ),
                  ProjectStatus.finished =>
                    context.appController.watchFinishedProjectsForUser(user.id),
                },
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(width: 32, child: AppLoader()),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: ErrorState(
                        message:
                            'Error loading ${switch (widget._sectionType) {
                              ProjectStatus.todo => 'to do projects',
                              ProjectStatus.inProgress => 'in progress projects',
                              ProjectStatus.finished => 'finished projects',
                            }}: ${snapshot.error}',
                      ),
                    );
                  }

                  final projects = snapshot.data ?? [];

                  if (projects.isEmpty) {
                    return Center(
                      child: EmptyState(
                        title: 'Nothing here. For now.',
                        body: switch (widget._sectionType) {
                          ProjectStatus.todo =>
                            'This is where you\'ll find your to do projects.',
                          ProjectStatus.inProgress =>
                            'This is where you\'ll find your in progress projects.',
                          ProjectStatus.finished =>
                            'This is where you\'ll find your finished projects.',
                        },
                        buttonText: 'Start a project',
                        onButtonPressed: () async {
                          final project = await ProjectWizard.manageProject(
                            context,
                            ProjectWizardMode.create,
                          );

                          if (project != null && context.mounted) {
                            context.push('/projects/${project.id}');
                          }
                        },
                      ),
                    );
                  }

                  final filteredProjects = projects.where((project) {
                    final query = value.toLowerCase();
                    return project.name.toLowerCase().contains(query) ||
                        project.description.toLowerCase().contains(query);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: spacing4),
                        child: SizedBox(
                          height: 40,
                          child: ValueListenableBuilder(
                            valueListenable: widget._editPressed,
                            builder: (context, editPressed, child) {
                              return AppListItem(
                                title: project.name,
                                description: project.description.isEmpty
                                    ? 'No description provided.'
                                    : project.description,
                                control:
                                    editPressed && project.ownerId == user.id
                                    ? AppListItemControl.largeButton
                                    : AppListItemControl.none,
                                largeButtonText:
                                    editPressed && project.ownerId == user.id
                                    ? 'Delete'
                                    : null,
                                onPressed:
                                    editPressed && project.ownerId == user.id
                                    ? () {
                                        context.appController.deleteProject(
                                          project.id,
                                        );
                                      }
                                    : () {
                                        context.push('/projects/${project.id}');
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
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }
}

class ProjectsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> editPressed;

  const ProjectsAppBar({super.key, required this.editPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ProjectsAppBar> createState() => _ProjectsAppBarState();
}

class _ProjectsAppBarState extends State<ProjectsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: widget.editPressed,
        builder: (context, editPressed, child) {
          return AppNavBar(
            title: 'Projects',
            leftText: editPressed ? 'Done' : 'Edit',
            rightIcon: AppIcons.create,
            onPressedLeft: () {
              widget.editPressed.value = !widget.editPressed.value;
            },
            onPressedRight: () {
              ProjectWizard.manageProject(
                context,
                ProjectWizardMode.create,
              ).then((project) {
                if (project != null && context.mounted) {
                  context.push('/projects/${project.id}');
                }
              });
            },
          );
        },
      ),
    );
  }
}
