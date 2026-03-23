import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/task_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_dropdown.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';

enum TaskWizardMode { create, edit }

class TaskWizard extends StatefulWidget {
  final String projectId;
  final TaskWizardMode mode;
  final Task? taskToEdit;

  const TaskWizard({
    super.key,
    required this.projectId,
    required this.mode,
    this.taskToEdit,
  }) : assert(
         mode == TaskWizardMode.edit ? taskToEdit != null : true,
         'taskToEdit must be provided in edit mode',
       );

  static Future<Task?> manageTask(
    BuildContext context,
    String projectId,
    TaskWizardMode mode, [
    Task? taskToEdit,
  ]) async {
    return await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) =>
          TaskWizard(projectId: projectId, mode: mode, taskToEdit: taskToEdit),
    );
  }

  @override
  State<TaskWizard> createState() => _TaskWizardState();
}

class _TaskWizardState extends State<TaskWizard> {
  final _selectedStatus = ValueNotifier<TaskStatus>(TaskStatus.todo);
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priority = ValueNotifier<TaskPriority>(TaskPriority.low);

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.mode == TaskWizardMode.edit && widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedStatus.value = task.status;
      _priority.value = task.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: widget.mode == TaskWizardMode.create
            ? context.l10n.createATaskTitle
            : context.l10n.editTaskTitle,
        leftText: context.l10n.cancelLabel,
        onPressedLeft: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          spacing: spacing8,
          children: [
            Expanded(
              child: _TaskWizardForm(
                projectId: widget.projectId,
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                mode: widget.mode,
                taskToEdit: widget.taskToEdit,
                selectedStatus: _selectedStatus,
                priority: _priority,
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
    switch (widget.mode) {
      case TaskWizardMode.create:
        final task = await context.projectController!.createTaskForProject(
          projectId: widget.projectId,
          taskTitle: _titleController.text,
          taskDescription: _descriptionController.text,
          priority: _priority.value,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop(task);
        break;
      case TaskWizardMode.edit:
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          status: _selectedStatus.value,
          priority: _priority.value,
        );
        await context.projectController!.updateTask(
          widget.projectId,
          updatedTask,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop(updatedTask);
        break;
    }
  }
}

class _TaskWizardForm extends StatefulWidget {
  final String _projectId;
  final GlobalKey<FormState> _formKey;
  final TextEditingController _titleController;
  final TextEditingController _descriptionController;
  final TaskWizardMode _mode;
  final Task? _taskToEdit;
  final ValueNotifier<TaskStatus> _selectedStatus;
  final ValueNotifier<TaskPriority> _priority;

  const _TaskWizardForm({
    required String projectId,
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required TaskWizardMode mode,
    required Task? taskToEdit,
    required ValueNotifier<TaskStatus> selectedStatus,
    required ValueNotifier<TaskPriority> priority,
  }) : _mode = mode,
       _taskToEdit = taskToEdit,
       _formKey = formKey,
       _titleController = titleController,
       _descriptionController = descriptionController,
       _selectedStatus = selectedStatus,
       _priority = priority,
       _projectId = projectId;

  @override
  State<_TaskWizardForm> createState() => _TaskWizardFormState();
}

class _TaskWizardFormState extends State<_TaskWizardForm> {
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _priorityFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget._formKey,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: ListView(
          children: [
            AppTextField(
              title: context.l10n.taskTitleLabel,
              placeholder: context.l10n.enterTaskTitleLabel,
              controller: widget._titleController,
              focusNode: _titleFocusNode,
              validator: getValidatorForKeyboardType(
                context,
                TextInputType.text,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(_priorityFocusNode);
              },
            ),
            const SizedBox(height: spacing16),
            AppDropdown(
              title: context.l10n.taskPriorityLabel,
              focusNode: _priorityFocusNode,
              items: [
                DropdownMenuEntry(
                  value: TaskPriority.low.name,
                  label: context.l10n.taskPriorityLowLabel,
                ),
                DropdownMenuEntry(
                  value: TaskPriority.medium.name,
                  label: context.l10n.taskPriorityMediumLabel,
                ),
                DropdownMenuEntry(
                  value: TaskPriority.high.name,
                  label: context.l10n.taskPriorityHighLabel,
                ),
              ],
              textInputAction: TextInputAction.next,
              onSelected: (value) {
                widget._priority.value = TaskPriority.values.firstWhere(
                  (e) => e.name == value.$1,
                );
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
            ),
            if (widget._mode == TaskWizardMode.edit)
              const SizedBox(height: spacing16),
            if (widget._mode == TaskWizardMode.edit &&
                widget._taskToEdit!.status != TaskStatus.finished)
              ValueListenableBuilder<TaskStatus>(
                valueListenable: widget._selectedStatus,
                builder: (context, value, child) {
                  if (widget._taskToEdit!.status == TaskStatus.finished) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusLabel(context, widget._taskToEdit!.status),
                        style: TextStyle(
                          fontSize: h5Size,
                          fontWeight: h5Weight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundStrongestColor,
                        ),
                      ),
                      AppCheckbox(
                        value: _getCheckboxValue(widget._taskToEdit!.status),
                        onChanged: (newValue) => _onStatusChanged(
                          widget._taskToEdit!.status,
                          newValue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: spacing16),
            AppTextArea(
              title: context.l10n.descriptionLabel,
              placeholder: context.l10n.enterTaskDescriptionLabel,
              controller: widget._descriptionController,
              focusNode: _descriptionFocusNode,
              textInputAction: TextInputAction.newline,
            ),
            if (widget._mode == TaskWizardMode.edit)
              const SizedBox(height: spacing16),
            if (widget._mode == TaskWizardMode.edit)
              AppButtonPrimary(
                text: context.l10n.deleteLabel,
                onPressed: () async {
                  await context.projectController!.deleteTask(
                    widget._projectId,
                    widget._taskToEdit!.id,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: spacing16),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return context.l10n.inProgressLabel;
      case TaskStatus.inProgress:
      case TaskStatus.finished:
        return context.l10n.finishedLabel;
    }
  }

  bool _getCheckboxValue(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return widget._selectedStatus.value == TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return widget._selectedStatus.value == TaskStatus.finished;
      case TaskStatus.finished:
        return true;
    }
  }

  void _onStatusChanged(TaskStatus status, bool? newValue) {
    if (newValue == null) return;
    if (status == TaskStatus.todo) {
      widget._selectedStatus.value = newValue
          ? TaskStatus.inProgress
          : TaskStatus.todo;
    } else if (status == TaskStatus.inProgress) {
      widget._selectedStatus.value = newValue
          ? TaskStatus.finished
          : TaskStatus.inProgress;
    }
  }
}
