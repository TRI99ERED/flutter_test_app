import 'package:flutter/material.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';

class AppScope extends StatefulWidget {
  final Widget child;
  final AppController controller;
  final ValueNotifier<ThemeMode> themeMode;

  const AppScope({
    super.key,
    required this.child,
    required this.controller,
    required this.themeMode,
  });

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AppController _controller;
  late AppState _state;

  UserEntity get user => _state.user;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _state = _controller.state;

    _controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    setState(() {
      _state = _controller.state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedScopeWidget(
      key: ValueKey(switch (user) {
        AuthorizedUser(:final id) => id,
        UnauthorizedUser() => 'unauthorized',
        _ => 'unknown',
      }),
      controller: _controller,
      state: _state,
      themeMode: widget.themeMode,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    super.dispose();
  }
}

class InheritedScopeWidget extends InheritedWidget {
  final AppController controller;
  final AppState state;
  final ValueNotifier<ThemeMode> themeMode;

  const InheritedScopeWidget({
    super.key,
    required this.controller,
    required this.state,
    required this.themeMode,
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
    return state != oldWidget.state || themeMode != oldWidget.themeMode;
  }
}

extension AppScopeExtension on BuildContext {
  AppState get appState =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.state;
  AppController get appController =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.controller;
  ValueNotifier<ThemeMode> get themeMode =>
      dependOnInheritedWidgetOfExactType<InheritedScopeWidget>()!.themeMode;
}
