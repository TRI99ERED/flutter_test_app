import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
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
    return await showDialog(
      context: context,
      barrierColor: Colors.transparent,
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
            ? context.l10n.createAProjectTitle
            : context.l10n.editProjectTitle,
        leftText: context.l10n.cancelLabel,
        onPressedLeft: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          spacing: spacing8,
          children: [
            Expanded(
              child: _ProjectWizardForm(
                formKey: _formKey,
                nameController: _nameController,
                descriptionController: _descriptionController,
                mode: widget.mode,
                projectToEdit: widget.projectToEdit,
                deadline: _deadline,
                selectedStatus: _selectedStatus,
                participants: _participants,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                text: context.l10n.saveLabel,
                onPressed: () => _onSavePressed(context),
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

  Future<void> _onSavePressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.appState.user as AuthorizedUser;
    switch (widget.mode) {
      case ProjectWizardMode.create:
        final project = await context.projectController!.createProjectForUser(
          projectName: _nameController.text,
          projectDescription: _descriptionController.text,
          participants: {user.id, ..._participants.value}.toList(),
          deadline: _deadline.value,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop(project);
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
        await context.projectController!.updateProject(updatedProject);
        if (!context.mounted) return;
        Navigator.of(context).pop(updatedProject);
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

class _ProjectWizardForm extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final TextEditingController _descriptionController;
  final ProjectWizardMode _mode;
  final Project? _projectToEdit;
  final ValueNotifier<DateTime> _deadline;
  final ValueNotifier<ProjectStatus> _selectedStatus;
  final ValueNotifier<List<String>> _participants;

  const _ProjectWizardForm({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required ProjectWizardMode mode,
    required Project? projectToEdit,
    required ValueNotifier<DateTime> deadline,
    required ValueNotifier<ProjectStatus> selectedStatus,
    required ValueNotifier<List<String>> participants,
  }) : _mode = mode,
       _projectToEdit = projectToEdit,
       _formKey = formKey,
       _nameController = nameController,
       _descriptionController = descriptionController,
       _deadline = deadline,
       _selectedStatus = selectedStatus,
       _participants = participants;

  @override
  State<_ProjectWizardForm> createState() => _ProjectWizardFormState();
}

class _ProjectWizardFormState extends State<_ProjectWizardForm> {
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget._formKey,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: ListView(
          children: [
            AppTextField(
              focusNode: _titleFocusNode,
              title: context.l10n.projectNameLabel,
              placeholder: context.l10n.enterProjectNameLabel,
              controller: widget._nameController,
              validator: getValidatorForKeyboardType(
                context,
                TextInputType.text,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
            ),
            if (widget._mode == ProjectWizardMode.edit)
              const SizedBox(height: spacing16),
            if (widget._mode == ProjectWizardMode.edit &&
                widget._projectToEdit!.status != ProjectStatus.finished)
              ValueListenableBuilder<ProjectStatus>(
                valueListenable: widget._selectedStatus,
                builder: (context, value, child) {
                  if (widget._projectToEdit!.status == ProjectStatus.finished) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusLabel(context, widget._projectToEdit!.status),
                        style: TextStyle(
                          fontSize: h5Size,
                          fontWeight: h5Weight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundStrongestColor,
                        ),
                      ),
                      AppCheckbox(
                        value: _getCheckboxValue(widget._projectToEdit!.status),
                        onChanged: (newValue) => _onStatusChanged(
                          widget._projectToEdit!.status,
                          newValue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: spacing16),
            AppTextArea(
              focusNode: _descriptionFocusNode,
              title: context.l10n.descriptionLabel,
              placeholder: context.l10n.enterProjectDescriptionLabel,
              controller: widget._descriptionController,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.participantsLabel,
                  style: TextStyle(
                    fontSize: h5Size,
                    fontWeight: h5Weight,
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundStrongestColor,
                  ),
                ),
                AppButtonPrimary(
                  text: context.l10n.addAParticipantLabel,
                  onPressed: () => _onAddMemberPressed(context),
                ),
              ],
            ),
            const SizedBox(height: spacing16),
            ValueListenableBuilder<List<String>>(
              valueListenable: widget._participants,
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
                          stream: context.appController.watchUserWithId(
                            memberId,
                          ),
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
                              largeButtonText: isCurrentUser
                                  ? null
                                  : context.l10n.removeLabel,
                              onPressed: isCurrentUser
                                  ? null
                                  : () {
                                      widget._participants.value = [
                                        ...widget._participants.value,
                                      ]..removeAt(index);
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
            const SizedBox(height: spacing16),
            Text(
              context.l10n.setDeadlineLabel,
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
                  widget._mode == ProjectWizardMode.edit &&
                      widget._projectToEdit != null
                  ? widget._deadline.value
                  : null,
              onDateSelected: (value) {
                widget._deadline.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo:
        return context.l10n.inProgressLabel;
      case ProjectStatus.inProgress:
      case ProjectStatus.finished:
        return context.l10n.finishedLabel;
    }
  }

  bool _getCheckboxValue(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo:
        return widget._selectedStatus.value == ProjectStatus.inProgress;
      case ProjectStatus.inProgress:
        return widget._selectedStatus.value == ProjectStatus.finished;
      case ProjectStatus.finished:
        return true;
    }
  }

  void _onStatusChanged(ProjectStatus status, bool? newValue) {
    if (newValue == null) return;
    if (status == ProjectStatus.todo) {
      widget._selectedStatus.value = newValue
          ? ProjectStatus.inProgress
          : ProjectStatus.todo;
    } else if (status == ProjectStatus.inProgress) {
      widget._selectedStatus.value = newValue
          ? ProjectStatus.finished
          : ProjectStatus.inProgress;
    }
  }

  void _onAddMemberPressed(BuildContext context) {
    if (widget._mode == ProjectWizardMode.create) {
      UserPicker.pickUser(context, UserPickerFlag.friendsOnly.value).then((
        selectedUser,
      ) {
        if (selectedUser != null &&
            !widget._participants.value.contains(selectedUser.id)) {
          widget._participants.value = [
            ...widget._participants.value,
            selectedUser.id,
          ];
        }
      });
    } else {
      if (widget._projectToEdit == null) return;
      UserPicker.pickUser(
        context,
        UserPickerFlag.friendsOnly.value |
            UserPickerFlag.excludeProjectParticipants.value,
        widget._projectToEdit!.id,
      ).then((selectedUser) {
        if (selectedUser != null) {
          widget._participants.value = [
            ...widget._participants.value,
            selectedUser.id,
          ];
        }
      });
    }
  }
}
