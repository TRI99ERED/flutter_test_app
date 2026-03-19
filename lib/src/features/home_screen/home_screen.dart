import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/home_screen/widgets/chats.dart';
import 'package:test_app/src/features/home_screen/widgets/friends.dart';
import 'package:test_app/src/features/home_screen/widgets/projects.dart';
import 'package:test_app/src/features/home_screen/widgets/settings.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_tap_bar.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  final int initialFriendsSection;
  final int initialProjectsSection;

  const HomeScreen({
    super.key,
    this.initialTab = 0,
    this.initialFriendsSection = 0,
    this.initialProjectsSection = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _selectedTabIndex = ValueNotifier<int>(widget.initialTab);
  final _editPressed = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        if (!previous.isAuthorized && current.isAuthorized) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        if (current.isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongColor,
              content: Text(
                '${context.l10n.errorLabel}: ${current.message}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
            ),
          );
        } else if (!current.isAuthorized && previous.isAuthorized) {
          context.go(loginPath);
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _selectedTabIndex,
        builder: (context, index, child) {
          return Scaffold(
            appBar: switch (index) {
              0 => ChatsAppBar(editPressed: _editPressed),
              1 => FriendsAppBar(editPressed: _editPressed),
              2 => ProjectsAppBar(editPressed: _editPressed),
              3 => const SettingsAppBar(),
              _ => null,
            },
            bottomNavigationBar: AppTapBar(
              tabCount: 4,
              selectedIndex: index,
              tabTitles: [
                context.l10n.chatsTitle,
                context.l10n.friendsTitle,
                context.l10n.projectsTitle,
                context.l10n.settingsTitle,
              ],
              tabIcons: [
                AppIcons.chat,
                AppIcons.profile,
                AppIcons.edit,
                AppIcons.settings,
              ],
              onTabSelected: (value) {
                _selectedTabIndex.value = value;
                _editPressed.value = false;
              },
            ),
            body: switch (index) {
              0 => Chats(editPressed: _editPressed),
              1 => Friends(
                editPressed: _editPressed,
                initialSection: widget.initialFriendsSection,
              ),
              2 => Projects(
                editPressed: _editPressed,
                initialSection: widget.initialProjectsSection,
              ),
              3 => const Settings(),
              _ => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}
