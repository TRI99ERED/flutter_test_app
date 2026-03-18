import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_dialog.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/user_profile.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.appState.user;
    if (user is AuthorizedUser) {
      return ListView(
        children: [
          Center(
            child: Stack(
              children: [
                AppAvatar.avatarOrPlaceholder(user, AvatarSize.large),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).extension<AppTheme>()?.highlightDarkestColor,
                      ),
                      onPressed: () {
                        UserProfile.show(
                          context,
                          user,
                          mode: UserProfileMode.edit,
                        );
                      },
                      icon: Icon(
                        AppIcons.edit,
                        size: 10,
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.backgroundStrongestColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: user.name.isNotEmpty
                ? Text(
                    user.name,
                    style: TextStyle(
                      fontSize: h3Size,
                      fontWeight: h3Weight,
                      color: Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongestColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Center(
            child: user.handle.isNotEmpty
                ? Text(
                    '@${user.handle}',
                    style: TextStyle(
                      fontSize: bSSize,
                      fontWeight: bSWeight,
                      color: Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Center(
            child: AppListItem(
              title: context.l10n.savedMessagesTitle,
              control: AppListItemControl.smallButton,
              onPressed: () {
                context.push(savedMessagesPath);
              },
            ),
          ),
          AppDivider(),
          Center(
            child: AppListItem(
              title: context.l10n.notificationsTitle,
              control: AppListItemControl.smallButton,
              onPressed: () {
                context.push(notificationsPath);
              },
            ),
          ),
          AppDivider(),
          Center(
            child: AppListItem(
              title: context.l10n.appearanceTitle,
              control: AppListItemControl.smallButton,
              onPressed: () {
                context.push(appearancePath);
              },
            ),
          ),
          AppDivider(),
          Center(
            child: AppListItem(
              title: context.l10n.languageTitle,
              control: AppListItemControl.smallButton,
              onPressed: () {},
            ),
          ),
          AppDivider(),
          Center(
            child: AppListItem(
              title: context.l10n.logOutLabel,
              control: AppListItemControl.smallButton,
              onPressed: () {
                AppDialog2.show(
                  context: context,
                  title: context.l10n.logOutLabel,
                  description: context.l10n.areYouSureYouWantToLogOutLabel,
                  buttonText1: context.l10n.cancelLabel,
                  buttonText2: context.l10n.logOutLabel,
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
    return const SizedBox.shrink();
  }
}

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: AppNavBar(title: context.l10n.settingsTitle));
  }
}
