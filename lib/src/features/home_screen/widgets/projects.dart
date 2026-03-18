import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_filter.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/app_sort.dart';
import 'package:test_app/src/widgets/project_wizard.dart';
import 'package:test_app/src/widgets/common/app_content_switcher.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/empty_state.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/features/themes/styles.dart';

class Projects extends StatefulWidget {
  final int initialSection;
  final ValueNotifier<bool> editPressed;

  const Projects({
    super.key,
    this.initialSection = 0,
    required this.editPressed,
  });

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  late final _sectionIndex = ValueNotifier<int>(widget.initialSection);
  final _sortOption = ValueNotifier<String>('lastUpdated');
  final _sortOrder = ValueNotifier<SortOrder>(SortOrder.descending);
  final _filters = ValueNotifier<Map<String, Set<String>>>({});

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
              builder: (context, sectionIndex, child) {
                return switch (sectionIndex) {
                  0 => _ProjectsSection(
                    sectionType: ProjectStatus.todo,
                    editPressed: widget.editPressed,
                    sortOption: _sortOption,
                    sortOrder: _sortOrder,
                    filters: _filters,
                  ),
                  1 => _ProjectsSection(
                    sectionType: ProjectStatus.inProgress,
                    editPressed: widget.editPressed,
                    sortOption: _sortOption,
                    sortOrder: _sortOrder,
                    filters: _filters,
                  ),
                  2 => _ProjectsSection(
                    sectionType: ProjectStatus.finished,
                    editPressed: widget.editPressed,
                    sortOption: _sortOption,
                    sortOrder: _sortOrder,
                    filters: _filters,
                  ),
                  _ => ErrorState(
                    message:
                        '${context.l10n.invalidSectionIndexMessage}: $sectionIndex',
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
    _sortOption.dispose();
    _sortOrder.dispose();
    super.dispose();
  }
}

class _ProjectsSection extends StatefulWidget {
  final ProjectStatus _sectionType;
  final ValueNotifier<bool> _editPressed;
  final ValueNotifier<String> _sortOption;
  final ValueNotifier<SortOrder> _sortOrder;
  final ValueNotifier<Map<String, Set<String>>> _filters;

  const _ProjectsSection({
    required ProjectStatus sectionType,
    required ValueNotifier<bool> editPressed,
    required ValueNotifier<String> sortOption,
    required ValueNotifier<SortOrder> sortOrder,
    required ValueNotifier<Map<String, Set<String>>> filters,
  }) : _sectionType = sectionType,
       _editPressed = editPressed,
       _sortOption = sortOption,
       _sortOrder = sortOrder,
       _filters = filters;

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
      return ErrorState(message: context.l10n.userNotAuthorizedMessage);
    }

    return Column(
      children: [
        StreamBuilder(
          stream: context.appController.watchUserWithId(user.id),
          builder: (context, asyncSnapshot) {
            final syncedUser = asyncSnapshot.data;
            return AppSearchBar(
              placeholder: context.l10n.searchLabel,
              recentSearches: syncedUser?.projectRecentSearches ?? [],
              onChanged: (value) => _searchQuery.value = value,
              onSubmitted: (value) async {
                _searchQuery.value = value;
                if (syncedUser == null) return;
                if (value.trim().isEmpty) return;
                final updatedSearches = [
                  value,
                  ...syncedUser.projectRecentSearches.where(
                    (entry) => entry != value,
                  ),
                ];
                await context.appController.updateUser(
                  syncedUser.copyWith(projectRecentSearches: updatedSearches)
                      as AuthorizedUser,
                );
              },
              onDelete: (value) async {
                if (syncedUser == null) return;
                final updatedSearches = syncedUser.projectRecentSearches
                    .where((entry) => entry != value)
                    .toList();
                await context.appController.updateUser(
                  syncedUser.copyWith(projectRecentSearches: updatedSearches)
                      as AuthorizedUser,
                );
              },
            );
          },
        ),
        const SizedBox(height: spacing8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: widget._sortOrder,
              builder: (context, sortOrder, child) {
                return AppSort(
                  sortOrder: sortOrder,
                  onPressed: () {
                    AppSortMenu.show(
                      context,
                      sortOption: widget._sortOption,
                      sortOrder: widget._sortOrder,
                      sortOptions: {
                        'lastUpdated': context.l10n.lastUpdatedLabel,
                        'name': context.l10n.nameLabel,
                        'createdAt': context.l10n.createdAtLabel,
                      },
                      defaultSortOption: 'lastUpdated',
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: widget._filters,
              builder: (context, value, child) {
                final creatorsFuture = switch (widget._sectionType) {
                  ProjectStatus.todo => () async {
                    final appController = context.appController;
                    final userId = (context.appState.user as AuthorizedUser).id;
                    final projects = await appController
                        .watchToDoProjectsForUser(userId)
                        .first;
                    if (projects == null) return <AuthorizedUser>[];
                    final creatorIds = projects.map((p) => p.ownerId).toSet()
                      ..removeWhere((id) => id.isEmpty);
                    final allUsers = await appController
                        .watchAllUsers()
                        .firstWhere(
                          (users) =>
                              users != null &&
                              users.any((u) => creatorIds.contains(u.id)),
                        );
                    return allUsers
                            ?.where((u) => creatorIds.contains(u.id))
                            .toList() ??
                        <AuthorizedUser>[];
                  }(),
                  ProjectStatus.inProgress => () async {
                    final appController = context.appController;
                    final userId = (context.appState.user as AuthorizedUser).id;
                    final projects = await appController
                        .watchInProgressProjectsForUser(userId)
                        .first;
                    if (projects == null) return <AuthorizedUser>[];
                    final creatorIds = projects.map((p) => p.ownerId).toSet()
                      ..removeWhere((id) => id.isEmpty);
                    final allUsers = await appController
                        .watchAllUsers()
                        .firstWhere(
                          (users) =>
                              users != null &&
                              users.any((u) => creatorIds.contains(u.id)),
                        );
                    return allUsers
                            ?.where((u) => creatorIds.contains(u.id))
                            .toList() ??
                        <AuthorizedUser>[];
                  }(),
                  ProjectStatus.finished => () async {
                    final appController = context.appController;
                    final userId = (context.appState.user as AuthorizedUser).id;
                    final projects = await appController
                        .watchFinishedProjectsForUser(userId)
                        .first;
                    if (projects == null) return <AuthorizedUser>[];
                    final creatorIds = projects.map((p) => p.ownerId).toSet()
                      ..removeWhere((id) => id.isEmpty);
                    final allUsers = await appController
                        .watchAllUsers()
                        .firstWhere(
                          (users) =>
                              users != null &&
                              users.any((u) => creatorIds.contains(u.id)),
                        );
                    return allUsers
                            ?.where((u) => creatorIds.contains(u.id))
                            .toList() ??
                        <AuthorizedUser>[];
                  }(),
                };

                return FutureBuilder(
                  future: creatorsFuture,
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const AppFilter(filteredItemCount: 0);
                    } else if (asyncSnapshot.hasError) {
                      return const AppFilter(filteredItemCount: 0);
                    }

                    final creators = asyncSnapshot.data ?? <AuthorizedUser>[];
                    final creatorIdToHandle = {
                      for (var u in creators) u.id: u.handle,
                    };

                    return AppFilter(
                      filteredItemCount:
                          widget._filters.value['creator']?.length ?? 0,
                      onPressed: () {
                        AppFilterMenu.show(
                          context,
                          filters: widget._filters,
                          filterOptions: {
                            MapEntry('creator', context.l10n.creatorTitle):
                                creatorIdToHandle,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: spacing8),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget._filters,
            builder: (context, value, child) {
              return ValueListenableBuilder(
                valueListenable: widget._sortOrder,
                builder: (context, value, child) {
                  return ValueListenableBuilder(
                    valueListenable: widget._sortOption,
                    builder: (context, value, child) {
                      return ValueListenableBuilder(
                        valueListenable: _searchQuery,
                        builder: (context, value, child) {
                          return StreamBuilder(
                            stream: switch (widget._sectionType) {
                              ProjectStatus.todo =>
                                context.appController
                                    .watchToDoProjectsForUser(
                                      user.id,
                                      widget._sortOption.value,
                                      widget._sortOrder.value ==
                                          SortOrder.descending,
                                    )
                                    .asyncMap((projects) async {
                                      if (projects == null) return null;
                                      return projects.where((project) {
                                        final creatorFilter =
                                            widget._filters.value['creator'];
                                        if (creatorFilter != null &&
                                            creatorFilter.isNotEmpty &&
                                            !creatorFilter.contains(
                                              project.ownerId,
                                            )) {
                                          return false;
                                        }
                                        return true;
                                      }).toList();
                                    }),
                              ProjectStatus.inProgress =>
                                context.appController
                                    .watchInProgressProjectsForUser(
                                      user.id,
                                      widget._sortOption.value,
                                      widget._sortOrder.value ==
                                          SortOrder.descending,
                                    )
                                    .asyncMap((projects) async {
                                      if (projects == null) return null;
                                      return projects.where((project) {
                                        final creatorFilter =
                                            widget._filters.value['creator'];
                                        if (creatorFilter != null &&
                                            creatorFilter.isNotEmpty &&
                                            !creatorFilter.contains(
                                              project.ownerId,
                                            )) {
                                          return false;
                                        }
                                        return true;
                                      }).toList();
                                    }),
                              ProjectStatus.finished =>
                                context.appController
                                    .watchFinishedProjectsForUser(
                                      user.id,
                                      widget._sortOption.value,
                                      widget._sortOrder.value ==
                                          SortOrder.descending,
                                    )
                                    .asyncMap((projects) async {
                                      if (projects == null) return null;
                                      return projects.where((project) {
                                        final creatorFilter =
                                            widget._filters.value['creator'];
                                        if (creatorFilter != null &&
                                            creatorFilter.isNotEmpty &&
                                            !creatorFilter.contains(
                                              project.ownerId,
                                            )) {
                                          return false;
                                        }
                                        return true;
                                      }).toList();
                                    }),
                            },
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    width: 32,
                                    child: AppLoader(),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: ErrorState(
                                    message:
                                        '${switch (widget._sectionType) {
                                          ProjectStatus.todo => context.l10n.errorLoadingToDoProjectsMessage,
                                          ProjectStatus.inProgress => context.l10n.errorLoadingInProgressProjectsMessage,
                                          ProjectStatus.finished => context.l10n.errorLoadingFinishedProjectsMessage,
                                        }}: ${snapshot.error}',
                                  ),
                                );
                              }

                              final projects = snapshot.data ?? [];

                              if (projects.isEmpty) {
                                return Center(
                                  child: EmptyState(
                                    title: context.l10n.nothingHereForNowLabel,
                                    body: switch (widget._sectionType) {
                                      ProjectStatus.todo =>
                                        context
                                            .l10n
                                            .thisIsWhereYoullfindYourToDoProjectsLabel,
                                      ProjectStatus.inProgress =>
                                        context
                                            .l10n
                                            .thisIsWhereYoullfindYourInProgressProjectsLabel,
                                      ProjectStatus.finished =>
                                        context
                                            .l10n
                                            .thisIsWhereYoullfindYourFinishedProjectsLabel,
                                    },
                                    buttonText: context.l10n.startAProjectLabel,
                                    onButtonPressed: () async {
                                      final project =
                                          await ProjectWizard.manageProject(
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

                              final filteredProjects = projects.where((
                                project,
                              ) {
                                final query = value.toLowerCase();
                                return project.name.toLowerCase().contains(
                                      query,
                                    ) ||
                                    project.description.toLowerCase().contains(
                                      query,
                                    );
                              }).toList();

                              return ListView.builder(
                                itemCount: filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final project = filteredProjects[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: spacing4,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: widget._editPressed,
                                      builder: (context, editPressed, child) {
                                        return AppListItem(
                                          title: project.name,
                                          description:
                                              project.description.isEmpty
                                              ? context
                                                    .l10n
                                                    .noDescriptionProvidedLabel
                                              : project.description,
                                          control:
                                              editPressed &&
                                                  project.ownerId == user.id
                                              ? AppListItemControl.largeButton
                                              : AppListItemControl.none,
                                          largeButtonText:
                                              editPressed &&
                                                  project.ownerId == user.id
                                              ? context.l10n.deleteLabel
                                              : null,
                                          onPressed:
                                              editPressed &&
                                                  project.ownerId == user.id
                                              ? () {
                                                  context.appController
                                                      .deleteProject(
                                                        project.id,
                                                      );
                                                }
                                              : () {
                                                  context.push(
                                                    '/projects/${project.id}',
                                                  );
                                                },
                                        );
                                      },
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
            title: context.l10n.projectsTitle,
            leftText: editPressed
                ? context.l10n.doneLabel
                : context.l10n.editLabel,
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
