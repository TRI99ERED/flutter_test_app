import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_calendar.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/user_picker.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/features/themes/styles.dart';

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
  final _deadline = ValueNotifier<DateTime>(DateTime.now());
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.mode == ProjectWizardMode.edit && widget.projectToEdit != null) {
      final project = widget.projectToEdit!;
      _nameController.text = project.name;
      _descriptionController.text = project.description;
      _participants.value = project.participants;
      _selectedStatus.value = project.status;
      _deadline.value = project.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: widget.mode == ProjectWizardMode.create
            ? 'Create a Project'
            : 'Edit Project',
        leftText: 'Cancel',
        onPressedLeft: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          spacing: spacing8,
          children: [
            Expanded(child: _buildForm(context)),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                text: 'Save',
                onPressed: () => _onSavePressed(context),
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
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: ListView(
          children: [
            AppTextField(
              title: 'Project name',
              placeholder: 'Enter project name',
              controller: _nameController,
              validator: getValidatorForKeyboardType(TextInputType.text),
            ),
            if (widget.mode == ProjectWizardMode.edit)
              const SizedBox(height: spacing16),
            if (widget.mode == ProjectWizardMode.edit &&
                widget.projectToEdit!.status != ProjectStatus.finished)
              _buildStatusCheckbox(context),
            const SizedBox(height: spacing16),
            AppTextArea(
              title: 'Description',
              placeholder: 'Enter project description',
              controller: _descriptionController,
            ),
            const SizedBox(height: spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: h5Size,
                    fontWeight: h5Weight,
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundStrongestColor,
                  ),
                ),
                AppButtonPrimary(
                  text: 'Add a participant',
                  onPressed: () => _onAddMemberPressed(context),
                ),
              ],
            ),
            const SizedBox(height: spacing16),
            _buildParticipantsList(context),
            const SizedBox(height: spacing16),
            Text(
              'Set Deadline',
              style: TextStyle(
                fontSize: h5Size,
                fontWeight: h5Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            AppCalendarMonthly(
              initialDate:
                  widget.mode == ProjectWizardMode.edit &&
                      widget.projectToEdit != null
                  ? _deadline.value
                  : null,
              onDateSelected: (value) {
                _deadline.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCheckbox(BuildContext context) {
    final status = widget.projectToEdit!.status;
    return ValueListenableBuilder<ProjectStatus>(
      valueListenable: _selectedStatus,
      builder: (context, value, child) {
        if (status == ProjectStatus.finished) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_getStatusLabel(status)),
            AppCheckbox(
              value: _getCheckboxValue(status),
              onChanged: (newValue) => _onStatusChanged(status, newValue),
            ),
          ],
        );
      },
    );
  }

  String _getStatusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo:
        return 'In Progress';
      case ProjectStatus.inProgress:
      case ProjectStatus.finished:
        return 'Finished';
    }
  }

  bool _getCheckboxValue(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo:
        return _selectedStatus.value == ProjectStatus.inProgress;
      case ProjectStatus.inProgress:
        return _selectedStatus.value == ProjectStatus.finished;
      case ProjectStatus.finished:
        return true;
    }
  }

  void _onStatusChanged(ProjectStatus status, bool? newValue) {
    if (newValue == null) return;
    if (status == ProjectStatus.todo) {
      _selectedStatus.value = newValue
          ? ProjectStatus.inProgress
          : ProjectStatus.todo;
    } else if (status == ProjectStatus.inProgress) {
      _selectedStatus.value = newValue
          ? ProjectStatus.finished
          : ProjectStatus.inProgress;
    }
  }

  void _onAddMemberPressed(BuildContext context) {
    if (widget.mode == ProjectWizardMode.create) {
      UserPicker.pickUser(context, UserPickerFlag.friendsOnly.value).then((
        selectedUser,
      ) {
        if (selectedUser != null &&
            !_participants.value.contains(selectedUser.id)) {
          _participants.value = [..._participants.value, selectedUser.id];
        }
      });
    } else {
      if (widget.projectToEdit == null) return;
      UserPicker.pickUser(
        context,
        UserPickerFlag.friendsOnly.value |
            UserPickerFlag.excludeProjectParticipants.value,
        widget.projectToEdit!.id,
      ).then((selectedUser) {
        if (selectedUser != null) {
          _participants.value = [..._participants.value, selectedUser.id];
        }
      });
    }
  }

  Widget _buildParticipantsList(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _participants,
      builder: (context, value, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final memberId = value[index];
            return Column(
              children: [
                StreamBuilder(
                  stream: context.appController.watchUserWithId(memberId),
                  builder: (context, snapshot) {
                    final participant = snapshot.data;
                    if (participant == null) {
                      return const SizedBox.shrink();
                    }
                    final currentUserId =
                        (context.appState.user as AuthorizedUser).id;
                    final isCurrentUser = memberId == currentUserId;
                    return AppListItem(
                      title: participant.name,
                      description: participant.handle.isNotEmpty
                          ? '@${participant.handle}'
                          : null,
                      avatar: AppAvatar.avatarOrPlaceholder(
                        participant,
                        AvatarSize.small,
                      ),
                      control: isCurrentUser
                          ? AppListItemControl.none
                          : AppListItemControl.largeButton,
                      largeButtonText: isCurrentUser ? null : 'Remove',
                      onPressed: isCurrentUser
                          ? null
                          : () {
                              _participants.value = [..._participants.value]
                                ..removeAt(index);
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
    );
  }

  Future<void> _onSavePressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.appState.user as AuthorizedUser;
    switch (widget.mode) {
      case ProjectWizardMode.create:
        final project = await context.appController.createProjectForUser(
          projectName: _nameController.text,
          projectDescription: _descriptionController.text,
          participants: {user.id, ..._participants.value}.toList(),
          deadline: _deadline.value,
        );
        if (!context.mounted) return;
        context.pop(project);
        break;
      case ProjectWizardMode.edit:
        final updatedProject = widget.projectToEdit!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          participants: [..._participants.value],
          status: _selectedStatus.value,
          deadline: _deadline.value,
          lastUpdated: DateTime.now(),
        );
        await context.appController.updateProject(updatedProject);
        if (!context.mounted) return;
        context.pop(updatedProject);
        break;
    }
  }

  @override
  void dispose() {
    _participants.dispose();
    _selectedStatus.dispose();
    _deadline.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
