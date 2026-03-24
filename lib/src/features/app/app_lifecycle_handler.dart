import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/router/app_router.dart';

class AppLifecycleHandler extends StatefulWidget {
  final AppRouterDelegate routerDelegate;
  final Widget child;

  const AppLifecycleHandler({
    super.key,
    required this.routerDelegate,
    required this.child,
  });

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

    final router = widget.routerDelegate;
    final currentPage = router.currentPages.lastOrNull;
    if (currentPage == null) return;
    final currentPath = currentPage.path;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        if (currentPath.startsWith('/chats/direct/') ||
            currentPath.startsWith('/chats/group/')) {
          await appController.updateUser(
            user.copyWith(currentDirectChatId: '', currentGroupChatId: ''),
          );
        }
        await appController.updateUser(user.copyWith(isOnline: false));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (currentPath.startsWith('/chats/direct/') ||
            currentPath.startsWith('/chats/group/')) {
          await appController.updateUser(
            user.copyWith(currentDirectChatId: '', currentGroupChatId: ''),
          );
        }
        await appController.updateUser(user.copyWith(isOnline: true));
        break;
      case AppLifecycleState.resumed:
        if (currentPath.startsWith('/chats/direct/')) {
          final chatId = currentPath.split('/chats/direct/').last;
          final chatController = context.chatController;

          await appController.updateUser(
            user.copyWith(currentDirectChatId: chatId),
          );
          if (chatController != null) {
            chatController.updateDirectChatUnreadCount(
              chatId: chatId,
              unreadCount: 0,
            );
          }
        } else if (currentPath.startsWith('/chats/group/')) {
          final chatId = currentPath.split('/chats/group/').last;
          final chatController = context.chatController;
          await appController.updateUser(
            user.copyWith(currentGroupChatId: chatId),
          );
          if (chatController != null) {
            chatController.updateGroupChatCurrentUserUnreadCount(
              chatId: chatId,
              unreadCount: 0,
            );
          }
        }
        await appController.updateUser(user.copyWith(isOnline: true));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
