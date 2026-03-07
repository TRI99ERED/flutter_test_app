import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_dialog.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Settings extends StatelessWidget {
  final ValueNotifier<int> selectedTabIndex;

  const Settings({super.key, required this.selectedTabIndex});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Stack(
            children: [
              const PlaceholderAvatar(size: AvatarSize.large),
              Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: HighlightColor.darkest.color,
                    ),
                    onPressed: () {},
                    icon: Icon(
                      AppIcons.edit,
                      size: 10,
                      color: LightColor.lightest.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: (context.appState.user as AuthorizedUser).name != ''
              ? Text(
                  (context.appState.user as AuthorizedUser).name,
                  style: TextStyle(
                    fontSize: h3Size,
                    fontWeight: h3Weight,
                    color: DarkColor.darkest.color,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Center(
          child: (context.appState.user as AuthorizedUser).handle != ''
              ? Text(
                  '@${(context.appState.user as AuthorizedUser).handle}',
                  style: TextStyle(
                    fontSize: bSSize,
                    fontWeight: bSWeight,
                    color: DarkColor.light.color,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Center(
          child: AppListItem(
            title: 'Saved messages',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Recent calls',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Devices',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Notifications',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Appearance',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Language',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Privacy & Security',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Storage',
            control: AppListItemControl.button,
            onPressed: () {},
          ),
        ),
        AppDivider(),
        Center(
          child: AppListItem(
            title: 'Log out',
            control: AppListItemControl.button,
            onPressed: () {
              AppDialog2.show(
                context: context,
                title: 'Log out',
                description:
                    'Are you sure you want to log out? You\'ll need to login again to use the app.',
                buttonText1: 'Cancel',
                buttonText2: 'Log out',
                onPressed1: () => context.pop(),
                onPressed2: () {
                  context.pop();
                  context.appController.logout();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: AppNavBar(title: 'Settings'));
  }
}
