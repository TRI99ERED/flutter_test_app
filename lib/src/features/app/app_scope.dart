import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/home_screen/controllers/chat_controller.dart';
import 'package:test_app/src/features/home_screen/controllers/friends_controller.dart';
import 'package:test_app/src/features/home_screen/controllers/project_controller.dart';

class AppScope extends StatefulWidget {
  final Widget child;
  final AppController appController;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?> locale;

  const AppScope({
    super.key,
    required this.child,
    required this.appController,
    required this.themeMode,
    required this.locale,
  });

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AppController _appController;
  late AppState _appState;
  ChatController? _chatController;
  FriendController? _friendController;
  ProjectController? _projectController;

  UserEntity get user => _appState.user;

  @override
  void initState() {
    super.initState();
    _appController = widget.appController;
    _appState = _appController.state;

    _appController.addListener(_onStateChange);

    _maybeCreateChatController();
    _maybeCreateFriendController();
    _maybeCreateProjectController();
  }

  void _maybeCreateChatController() {
    if (_appState.isAuthorized && _chatController == null) {
      _chatController = ChatController(appController: _appController);
    }
  }

  void _maybeCreateFriendController() {
    if (_appState.isAuthorized && _friendController == null) {
      _friendController = FriendController(appController: _appController);
    }
  }

  void _maybeCreateProjectController() {
    if (_appState.isAuthorized && _projectController == null) {
      _projectController = ProjectController(appController: _appController);
    }
  }

  void _onStateChange() {
    if (mounted) {
      final previousState = _appState;
      _appState = _appController.state;

      if (previousState.isAuthorized != _appState.isAuthorized) {
        if (_appState.isAuthorized) {
          _chatController = ChatController(appController: _appController);
          _friendController = FriendController(appController: _appController);
          _projectController = ProjectController(appController: _appController);
        } else {
          _chatController?.dispose();
          _chatController = null;
          _friendController?.dispose();
          _friendController = null;
          _projectController?.dispose();
          _projectController = null;
        }
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedScopeWidget(
      appController: _appController,
      appState: _appState,
      themeMode: widget.themeMode,
      locale: widget.locale,
      chatController: _chatController,
      friendController: _friendController,
      projectController: _projectController,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _appController.removeListener(_onStateChange);
    _chatController?.dispose();
    super.dispose();
  }
}

class InheritedScopeWidget extends InheritedWidget {
  final AppController appController;
  final AppState appState;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?> locale;
  final ChatController? chatController;
  final FriendController? friendController;
  final ProjectController? projectController;

  const InheritedScopeWidget({
    super.key,
    required this.appController,
    required this.appState,
    required this.themeMode,
    required this.locale,
    this.chatController,
    this.friendController,
    this.projectController,
    required super.child,
  });

  static InheritedScopeWidget? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedScopeWidget>();
  }

  static InheritedScopeWidget of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'No InheritedScopeWidget found in context. Make sure to wrap your widget tree with an InheritedScopeWidget.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(InheritedScopeWidget oldWidget) {
    return appState != oldWidget.appState ||
        themeMode != oldWidget.themeMode ||
        locale != oldWidget.locale ||
        chatController != oldWidget.chatController ||
        friendController != oldWidget.friendController ||
        projectController != oldWidget.projectController;
  }
}

extension AppScopeExtension on BuildContext {
  AppState get appState =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.appState;
  AppController get appController =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.appController;
  ValueNotifier<ThemeMode> get themeMode =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.themeMode;
  ValueNotifier<Locale?> get locale =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.locale;
  ChatController? get chatController =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!
          .chatController;
  FriendController? get friendController =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!
          .friendController;
  ProjectController? get projectController =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!
          .projectController;
}
