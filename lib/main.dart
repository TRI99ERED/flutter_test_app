import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_app/src/app_controller.dart';
import 'package:test_app/src/app_home.dart';
import 'package:test_app/src/app_scope.dart';

void main() {
  runZonedGuarded(
    () {
      runApp(const App());
    },
    (error, stackTrace) {
      debugPrint('Uncaught error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      home: const AppHome(),
      builder: (context, child) => AppScope(
        controller: _controller,
        state: _controller.state,
        child: child!,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }
}
