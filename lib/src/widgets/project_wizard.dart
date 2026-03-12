import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/styles.dart';

enum ProjectWizardMode { create, edit }

class ProjectWizard extends StatefulWidget {
  final ProjectWizardMode mode;
  final Project? projectToEdit;

  const ProjectWizard({super.key, required this.mode, this.projectToEdit})
    : assert(
        mode == ProjectWizardMode.edit ? projectToEdit != null : true,
        'projectToEdit must be provided when mode is edit',
      );

  static Future<Project?> manageProject(
    BuildContext context,
    ProjectWizardMode mode, [
    Project? projectToEdit,
  ]) async {
    return await showDialog<Project?>(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) =>
          ProjectWizard(mode: mode, projectToEdit: projectToEdit),
    );
  }

  @override
  State<ProjectWizard> createState() => _ProjectWizardState();
}

class _ProjectWizardState extends State<ProjectWizard> {
  final _participants = ValueNotifier<List<String>>([]);
  final _selectedStatus = ValueNotifier<ProjectStatus>(ProjectStatus.todo);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mode == ProjectWizardMode.edit && widget.projectToEdit != null) {
      _nameController.text = widget.projectToEdit!.name;
      _descriptionController.text = widget.projectToEdit!.description;
      _participants.value = widget.projectToEdit!.participants;
      _selectedStatus.value = widget.projectToEdit!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(spacing32),
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.8,
        decoration: BoxDecoration(
          color: LightColor.lightest.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            spacing: spacing8,
            children: [
              AppListTitle(
                title: switch (widget.mode) {
                  ProjectWizardMode.create => 'Create a Project',
                  ProjectWizardMode.edit => 'Edit Project',
                },
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: ListView(
                      children: [
                        AppTextField(
                          title: 'Project name',
                          placeholder: 'Enter project name',
                          controller: _nameController,
                          validator: getValidatorForKeyboardType(
                            TextInputType.text,
                          ),
                        ),
                        if (widget.mode == ProjectWizardMode.edit)
                          const SizedBox(height: spacing16),
                        if (widget.mode == ProjectWizardMode.edit &&
                            widget.projectToEdit!.status !=
                                ProjectStatus.finished)
                          ValueListenableBuilder(
                            valueListenable: _selectedStatus,
                            builder: (context, value, child) {
                              if (widget.projectToEdit!.status !=
                                  ProjectStatus.finished) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(switch (widget.projectToEdit!.status) {
                                      ProjectStatus.todo => 'In Progress',
                                      ProjectStatus.inProgress => 'Finished',
                                      ProjectStatus.finished => 'Finished',
                                    }),
                                    AppCheckbox(
                                      value: switch (widget
                                          .projectToEdit!
                                          .status) {
                                        ProjectStatus.todo =>
                                          _selectedStatus.value ==
                                              ProjectStatus.inProgress,
                                        ProjectStatus.inProgress =>
                                          _selectedStatus.value ==
                                              ProjectStatus.finished,
                                        ProjectStatus.finished => true,
                                      },
                                      onChanged: (newValue) {
                                        if (newValue == null) return;
                                        if (widget.projectToEdit!.status ==
                                            ProjectStatus.todo) {
                                          _selectedStatus.value = newValue
                                              ? ProjectStatus.inProgress
                                              : ProjectStatus.todo;
                                        } else if (widget
                                                .projectToEdit!
                                                .status ==
                                            ProjectStatus.inProgress) {
                                          _selectedStatus.value = newValue
                                              ? ProjectStatus.finished
                                              : ProjectStatus.inProgress;
                                        }
                                      },
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        const SizedBox(height: spacing16),
                        AppTextArea(
                          title: 'Description',
                          placeholder: 'Enter project description',
                          controller: _descriptionController,
                        ),
                        const SizedBox(height: spacing16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppButtonPrimary(
                            text: 'Add a member',
                            onPressed: switch (widget.mode) {
                              ProjectWizardMode.create => () {
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
                              ProjectWizardMode.edit => () {
                                if (widget.projectToEdit == null) {
                                  return;
                                }

                                UserPicker.pickUser(
                                  context,
                                  UserPickerFlag.friendsOnly.value |
                                      UserPickerFlag
                                          .excludeProjectParticipants
                                          .value,
                                  widget.projectToEdit!.id,
                                ).then((selectedUser) {
                                  if (selectedUser != null) {
                                    _participants.value = [
                                      ..._participants.value,
                                      selectedUser.id,
                                    ];
                                  }
                                });
                              },
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
                                final memberId = _participants.value[index];
                                return Column(
                                  children: [
                                    StreamBuilder(
                                      stream: context.appController
                                          .watchUserWithId(memberId),
                                      builder: (context, snapshot) {
                                        final participant = snapshot.data;
                                        if (participant == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return AppListItem(
                                          title: participant.name,
                                          description: '@${participant.handle}',
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
                    if (_formKey.currentState?.validate() ?? false) {
                      final user = context.appState.user as AuthorizedUser;
                      switch (widget.mode) {
                        case ProjectWizardMode.create:
                          final project = await context.appController
                              .createProjectForUser(
                                projectName: _nameController.text,
                                projectDescription: _descriptionController.text,
                                participants: {
                                  user.id,
                                  ..._participants.value.map((id) => id),
                                }.toList(),
                              );

                          if (!context.mounted) return;
                          context.pop(project);
                          break;
                        case ProjectWizardMode.edit:
                          final updatedProject = widget.projectToEdit!.copyWith(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            participants: {
                              ..._participants.value.map((id) => id),
                            }.toList(),
                            status: _selectedStatus.value,
                            lastUpdated: DateTime.now(),
                          );

                          await context.appController.updateProject(
                            updatedProject,
                          );

                          if (!context.mounted) return;
                          context.pop(updatedProject);
                          break;
                      }
                    }
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
    );
  }

  @override
  void dispose() {
    _participants.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
