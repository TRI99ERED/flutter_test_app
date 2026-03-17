import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';

enum AppDividerType { horizontal, vertical }

class AppDivider extends StatelessWidget {
  final AppDividerType type;

  const AppDivider({super.key, this.type = AppDividerType.horizontal});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppDividerType.horizontal:
        return Divider(
          thickness: 0,
          color: Theme.of(context).extension<AppTheme>()?.backgroundWeakColor,
        );
      case AppDividerType.vertical:
        return VerticalDivider(
          thickness: 0,
          color: Theme.of(context).extension<AppTheme>()?.backgroundWeakColor,
        );
    }
  }
}
