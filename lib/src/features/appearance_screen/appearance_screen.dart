import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_radio_button.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
      },
      child: Scaffold(
        appBar: AppNavBar(
          title: 'Appearance',
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            context.pop();
          },
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(spacing16),
              child: Text(
                'Theme',
                style: TextStyle(
                  fontSize: h3Size,
                  fontWeight: h3Weight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                  fontFamily: GoogleFonts.inter().fontFamily,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: context.themeMode.value,
              onChanged: (value) {
                if (value != null) {
                  context.themeMode.value = value;
                }
              },
              child: Column(
                children: [
                  AppRadioTile(
                    value: ThemeMode.system,
                    title: 'System',
                    onChanged: (value) {
                      context.themeMode.value = value;
                    },
                  ),
                  AppRadioTile(
                    value: ThemeMode.light,
                    title: 'Light',
                    onChanged: (value) {
                      context.themeMode.value = value;
                    },
                  ),
                  AppRadioTile(
                    value: ThemeMode.dark,
                    title: 'Dark',
                    onChanged: (value) {
                      context.themeMode.value = value;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
