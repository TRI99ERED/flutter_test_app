import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyToastInformative extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const MyToastInformative({
    super.key,
    this.title,
    this.description,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: HighlightColor.lightest.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                AppIcons.info,
                size: 24,
                color: HighlightColor.darkest.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 8),
                    if (description != null)
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
              const SizedBox(width: 8),
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

class MyToastSuccess extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const MyToastSuccess({super.key, this.title, this.description, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: SuccessColor.light.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                AppIcons.success,
                size: 24,
                color: SuccessColor.medium.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 8),
                    if (description != null)
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
              const SizedBox(width: 8),
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

class MyToastWarning extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const MyToastWarning({super.key, this.title, this.description, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: WarningColor.light.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                AppIcons.warning,
                size: 24,
                color: WarningColor.medium.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 8),
                    if (description != null)
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
              const SizedBox(width: 8),
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

class MyToastError extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const MyToastError({super.key, this.title, this.description, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: ErrorColor.light.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(AppIcons.warning, size: 24, color: ErrorColor.medium.color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 8),
                    if (description != null)
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
              const SizedBox(width: 8),
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
