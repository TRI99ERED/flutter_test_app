import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/home_screen/widgets/chats.dart';
import 'package:test_app/src/features/home_screen/widgets/friends.dart';
import 'package:test_app/src/features/home_screen/widgets/projects.dart';
import 'package:test_app/src/features/home_screen/widgets/settings.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_tap_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _selectedTabIndex = ValueNotifier<int>(0);
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
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
              tabTitles: ['Chats', 'Friends', 'Projects', 'Settings'],
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
              1 => Friends(editPressed: _editPressed),
              2 => Projects(editPressed: _editPressed),
              3 => const Settings(),
              _ => SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}
