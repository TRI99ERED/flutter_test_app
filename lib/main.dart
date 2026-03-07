import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/styles.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Preload Inter font to avoid blocking the UI thread
      GoogleFonts.inter();
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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.addListener(_rebuild);
    _router = generateRouter(_controller);
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Test App',
      theme: ThemeData(
        buttonTheme: Theme.of(
          context,
        ).buttonTheme.copyWith(highlightColor: HighlightColor.darkest.color),
        colorScheme: ColorScheme.fromSeed(
          seedColor: HighlightColor.darkest.color,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        primaryTextTheme: GoogleFonts.interTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconTheme: IconThemeData(color: HighlightColor.darkest.color),
        scaffoldBackgroundColor: LightColor.lightest.color,
      ),
      routerConfig: _router,
      builder: (context, child) =>
          AppScope(controller: _controller, child: child!),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }
}
