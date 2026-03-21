import 'package:flutter/material.dart';
// TODO: Remove go_router once migration is complete
// import 'package:go_router/go_router.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/l10n/locales/l10n.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongColor,
            content: Text(
              'Error: ${current.message}',
              style: TextStyle(
                fontSize: cMSize,
                fontWeight: cMWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
          ),
        );
      },
      child: Scaffold(
        appBar: AppNavBar(
          title: context.l10n.appearanceTitle,
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            AppNavigator.of(context).pop();
          },
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(spacing16),
              child: Text(
                context.l10n.themeLabel,
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
            ValueListenableBuilder(
              valueListenable: context.themeMode,
              builder: (context, value, child) {
                return RadioGroup<ThemeMode>(
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
                        title: context.l10n.systemLabel,
                        onChanged: (value) {
                          context.themeMode.value = value;
                        },
                      ),
                      AppRadioTile(
                        value: ThemeMode.light,
                        title: context.l10n.lightLabel,
                        onChanged: (value) {
                          context.themeMode.value = value;
                        },
                      ),
                      AppRadioTile(
                        value: ThemeMode.dark,
                        title: context.l10n.darkLabel,
                        onChanged: (value) {
                          context.themeMode.value = value;
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
