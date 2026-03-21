import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/features/themes/styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing24,
          children: [
            Text(
              'Test App',
              style: TextStyle(
                fontSize: h1Size,
                fontWeight: h1Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            const AppLoader(),
          ],
        ),
      ),
    );
  }
}
