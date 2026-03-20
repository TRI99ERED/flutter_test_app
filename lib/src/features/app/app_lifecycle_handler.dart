import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    final appController = context.appController;
    final user = context.appState.user;
    if (user is! AuthorizedUser) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        await appController.updateUser(
          user.copyWith(currentDirectChatId: '', currentGroupChatId: '')
              as AuthorizedUser,
        );
        break;
      case AppLifecycleState.resumed:
        final matchedLocation = await appController.loadCurrentRoute();
        if (matchedLocation != null &&
            matchedLocation.startsWith('{chatType: direct, chatId: ')) {
          final chatId = matchedLocation
              .split('{chatType: direct, chatId: ')
              .last
              .split('}')
              .first;
          appController.updateUser(
            user.copyWith(currentDirectChatId: chatId) as AuthorizedUser,
          );
          appController.updateDirectChatUnreadCount(
            chatId: chatId,
            unreadCount: 0,
          );
        } else if (matchedLocation != null &&
            matchedLocation.startsWith('{chatType: group, chatId: ')) {
          final chatId = matchedLocation
              .split('{chatType: group, chatId: ')
              .last
              .split('}')
              .first;
          appController.updateUser(
            user.copyWith(currentGroupChatId: chatId) as AuthorizedUser,
          );
          appController.updateGroupChatCurrentUserUnreadCount(
            chatId: chatId,
            unreadCount: 0,
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
