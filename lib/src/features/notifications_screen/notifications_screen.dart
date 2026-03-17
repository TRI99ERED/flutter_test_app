import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final _enablePushNotifications = ValueNotifier<bool>(false);
  late final _enableMessageNotifications = ValueNotifier<bool>(false);
  late final _enableFriendRequestNotifications = ValueNotifier<bool>(false);
  late final _enableProjectInviteNotifications = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await context.appController.loadNotificationsSettings();
      _enablePushNotifications.value = settings.pushNotificationsEnabled;
      _enableMessageNotifications.value = settings.messageNotificationsEnabled;
      _enableFriendRequestNotifications.value =
          settings.friendRequestNotificationsEnabled;
      _enableProjectInviteNotifications.value =
          settings.projectInviteNotificationsEnabled;
    });
  }

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
          title: 'Notifications',
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            context.pop();
          },
        ),
        body: ListView(
          children: [
            ValueListenableBuilder(
              valueListenable: _enablePushNotifications,
              builder: (context, value, child) {
                return AppListItem(
                  title: 'Enable push notifications',
                  control: AppListItemControl.toggle,
                  value: value,
                  onChanged: (value) async {
                    _enablePushNotifications.value = value;
                    final appController = context.appController;
                    final settings = await appController
                        .loadNotificationsSettings();
                    await appController.saveNotificationsSettings(
                      settings.copyWith(pushNotificationsEnabled: value),
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _enableFriendRequestNotifications,
              builder: (context, value, child) {
                return AppListItem(
                  title: 'Enable friend request notifications',
                  control: AppListItemControl.toggle,
                  value: value,
                  onChanged: (value) async {
                    _enableFriendRequestNotifications.value = value;
                    final appController = context.appController;
                    final settings = await appController
                        .loadNotificationsSettings();
                    await appController.saveNotificationsSettings(
                      settings.copyWith(
                        friendRequestNotificationsEnabled: value,
                      ),
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _enableProjectInviteNotifications,
              builder: (context, value, child) {
                return AppListItem(
                  title: 'Enable project invite notifications',
                  control: AppListItemControl.toggle,
                  value: value,
                  onChanged: (value) async {
                    _enableProjectInviteNotifications.value = value;
                    final appController = context.appController;
                    final settings = await appController
                        .loadNotificationsSettings();
                    await appController.saveNotificationsSettings(
                      settings.copyWith(
                        projectInviteNotificationsEnabled: value,
                      ),
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _enableMessageNotifications,
              builder: (context, value, child) {
                return AppListItem(
                  title: 'Enable message notifications',
                  control: AppListItemControl.toggle,
                  value: value,
                  onChanged: (value) async {
                    _enableMessageNotifications.value = value;
                    final appController = context.appController;
                    final settings = await appController
                        .loadNotificationsSettings();
                    await appController.saveNotificationsSettings(
                      settings.copyWith(messageNotificationsEnabled: value),
                    );
                  },
                );
              },
            ),
            AppListItem(
              title: 'System notification settings',
              onPressed: () async {
                final intent = AndroidIntent(
                  action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                  arguments: <String, dynamic>{
                    'android.provider.extra.APP_PACKAGE':
                        'com.example.test_app',
                  },
                );
                await intent.launch();
              },
            ),
          ],
        ),
      ),
    );
  }
}
