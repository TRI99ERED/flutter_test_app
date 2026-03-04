import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppToastInformative extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const AppToastInformative({
    super.key,
    this.title,
    this.description,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _AppToastBase(
      title: title,
      description: description,
      onClose: onClose,
      backgroundColor: HighlightColor.lightest.color,
      leadingIcon: AppIcons.info,
      leadingIconColor: HighlightColor.darkest.color,
    );
  }
}

class AppToastSuccess extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const AppToastSuccess({
    super.key,
    this.title,
    this.description,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _AppToastBase(
      title: title,
      description: description,
      onClose: onClose,
      backgroundColor: SuccessColor.light.color,
      leadingIcon: AppIcons.success,
      leadingIconColor: SuccessColor.medium.color,
    );
  }
}

class AppToastWarning extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const AppToastWarning({
    super.key,
    this.title,
    this.description,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _AppToastBase(
      title: title,
      description: description,
      onClose: onClose,
      backgroundColor: WarningColor.light.color,
      leadingIcon: AppIcons.warning,
      leadingIconColor: WarningColor.medium.color,
    );
  }
}

class AppToastError extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const AppToastError({super.key, this.title, this.description, this.onClose});

  @override
  Widget build(BuildContext context) {
    return _AppToastBase(
      title: title,
      description: description,
      onClose: onClose,
      backgroundColor: ErrorColor.light.color,
      leadingIcon: AppIcons.delete,
      leadingIconColor: ErrorColor.medium.color,
    );
  }
}

class _AppToastBase extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;
  final Color backgroundColor;
  final IconData leadingIcon;
  final Color leadingIconColor;

  const _AppToastBase({
    this.title,
    this.description,
    this.onClose,
    required this.backgroundColor,
    required this.leadingIcon,
    required this.leadingIconColor,
  });

  bool get _hasTitle => (title ?? '').trim().isNotEmpty;
  bool get _hasDescription => (description ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    assert(
      _hasTitle || _hasDescription,
      'At least one of title or description must be provided',
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: EdgeInsets.all(spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(leadingIcon, size: 24, color: leadingIconColor),
              SizedBox(width: spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasTitle)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (_hasTitle && _hasDescription)
                      SizedBox(height: spacing8),
                    if (_hasDescription)
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: bSSize,
                          fontWeight: bSWeight,
                        ),
                        softWrap: true,
                      ),
                  ],
                ),
              ),
              SizedBox(width: spacing8),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  AppIcons.close,
                  size: 12,
                  color: DarkColor.light.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
