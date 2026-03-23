import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/data/models/task_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppTask extends StatelessWidget {
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final VoidCallback? onEditPressed;

  const AppTask({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(spacing16),
      margin: const EdgeInsets.symmetric(vertical: spacing4),
      decoration: BoxDecoration(
        color: switch (priority) {
          TaskPriority.low => Theme.of(
            context,
          ).extension<AppTheme>()?.successMediumColor,
          TaskPriority.medium => Theme.of(
            context,
          ).extension<AppTheme>()?.warningMediumColor,
          TaskPriority.high => Theme.of(
            context,
          ).extension<AppTheme>()?.errorMediumColor,
        },
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${switch (status) {
                    TaskStatus.todo => context.l10n.toDoLabel,
                    TaskStatus.inProgress => context.l10n.inProgressLabel,
                    TaskStatus.finished => context.l10n.finishedLabel,
                  }} • $title ',
                  style: TextStyle(
                    fontSize: h5Size,
                    fontWeight: h5Weight,
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundStrongestColor,
                  ),
                ),
                const SizedBox(height: spacing8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: bMSize,
                    fontWeight: bMWeight,
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundStrongColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: spacing16),
          IconButton(
            onPressed: onEditPressed,
            icon: Icon(
              AppIcons.edit,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
            ),
          ),
        ],
      ),
    );
  }
}
