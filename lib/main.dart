import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/l10n/locales/app_localizations.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_lifecycle_handler.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/services/notification_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await NotificationService.initialize();

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
  late final AppController _appController;
  late final GoRouter _router;
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    extensions: [appThemeLight],
    scaffoldBackgroundColor: appThemeLight.backgroundStrongestColor,
    textTheme: GoogleFonts.interTextTheme(),
    primaryTextTheme: GoogleFonts.interTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: appThemeLight.backgroundStrongColor,
      contentTextStyle: GoogleFonts.inter(
        color: appThemeLight.foregroundStrongestColor,
        fontSize: cMSize,
        fontWeight: cMWeight,
      ),
    ),
  );
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    extensions: [appThemeDark],
    scaffoldBackgroundColor: appThemeDark.backgroundStrongestColor,
    textTheme: GoogleFonts.interTextTheme(),
    primaryTextTheme: GoogleFonts.interTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: appThemeDark.backgroundStrongColor,
      contentTextStyle: GoogleFonts.inter(
        color: appThemeDark.foregroundStrongestColor,
        fontSize: cMSize,
        fontWeight: cMWeight,
      ),
    ),
  );
  final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  final _locale = ValueNotifier<Locale?>(null);

  @override
  void initState() {
    super.initState();
    _appController = AppController();
    _appController.addListener(_rebuild);
    _router = generateRouter(_appController, rootNavigatorKey);
  }

  void _rebuild() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _locale,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: _themeMode,
          builder: (context, value, child) {
            return MaterialApp.router(
              title: 'Test App',
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeMode: _themeMode.value,
              locale: _locale.value,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
              builder: (context, child) => AppScope(
                controller: _appController,
                themeMode: _themeMode,
                locale: _locale,
                child: child == null
                    ? const SizedBox.shrink()
                    : AppLifecycleHandler(child: child),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _appController.removeListener(_rebuild);
    _appController.dispose();
    super.dispose();
  }
}
