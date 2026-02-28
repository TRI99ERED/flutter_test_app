import 'package:flutter/material.dart';
import 'package:test_app/src/app_controller.dart';

class AppScope extends InheritedWidget {
  final AppController controller;
  final AppState state;

  const AppScope({
    super.key,
    required this.controller,
    required this.state,
    required super.child,
  });

  static AppScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>();
  }

  static AppScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'No AppScope found in context. Make sure to wrap your widget tree with an AppScope.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return state != oldWidget.state;
  }
}

extension AppScopeExtension on BuildContext {
  AppState get appState =>
      dependOnInheritedWidgetOfExactType<AppScope>()!.state;
  AppController get appController =>
      dependOnInheritedWidgetOfExactType<AppScope>()!.controller;
}
