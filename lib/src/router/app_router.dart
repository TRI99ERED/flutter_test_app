import 'package:flutter/material.dart';
import 'package:test_app/src/router/app_navigator.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/src/router/nav_log.dart';

// ---------------------------------------------------------------------------
// RouteInformationParser — converts platform URIs to/from page stacks
// ---------------------------------------------------------------------------

class AppRouteInformationParser
    extends RouteInformationParser<AppNavigationState> {
  const AppRouteInformationParser();

  @override
  Future<AppNavigationState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    final path = uri.path;

    // Ignore platform-reported transitional paths — the guard system
    // handles auth redirects, so the parser should not feed them back.
    if (path.isEmpty || path == '/' || _isTransitionalPath(path)) {
      return const [SplashPage()];
    }

    NavLog.d('Parse deep link: $path');
    try {
      final page = AppPage.fromRoute(path);
      return _buildStackForPage(page);
    } catch (_) {
      return const [SplashPage()];
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppNavigationState configuration) {
    if (configuration.isEmpty) return null;
    final top = configuration.last;
    // Don't report transitional pages to the platform.
    if (top is SplashPage || _isTransitionalPath(top.path)) return null;
    return RouteInformation(uri: Uri.parse(top.path));
  }

  static bool _isTransitionalPath(String path) {
    const transitional = {
      '/splash',
      '/onboarding',
      '/login',
      '/register',
      '/email-confirmation',
      '/forgot-password',
    };
    return transitional.contains(path);
  }

  /// Build a meaningful back stack so deep-linked detail screens
  /// have a parent to pop back to.
  static AppNavigationState _buildStackForPage(AppPage page) {
    return switch (page) {
      ChatPage() ||
      ProjectPage() ||
      ProjectFeedbackPage() ||
      SavedMessagesPage() ||
      NotificationsPage() ||
      AppearancePage() ||
      LanguagePage() ||
      InterestsPage() => [HomePage(), page],
      _ => [page],
    };
  }
}

// ---------------------------------------------------------------------------
// RouterDelegate — the bridge between platform and AppNavigator
// ---------------------------------------------------------------------------

class AppRouterDelegate extends RouterDelegate<AppNavigationState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppNavigationState> {
  AppRouterDelegate({
    required this.initialPages,
    required this.guards,
    this.refreshListenable,
    this.observers = const [],
  });

  final AppNavigationState initialPages;
  final List<AppNavigationGuard> guards;
  final Listenable? refreshListenable;
  final List<NavigatorObserver> observers;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppNavigatorState? _navigatorState;
  AppPage? _pendingNavigation;

  /// Whether the app has moved past the splash screen.
  /// Deep link setNewRoutePath calls are ignored until then.
  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Public API — used by services (notifications, deep links) without context
  // ---------------------------------------------------------------------------

  /// Navigate to a page from anywhere (services, notification handlers, etc.).
  /// No BuildContext needed. Skips if the page is already on top.
  /// Defers if the app hasn't finished initializing (splash/auth resolution).
  void navigateTo(AppPage page) {
    if (!_initialized) {
      NavLog.d('Router: navigateTo deferred until init (${page.name})');
      _pendingNavigation = page;
      return;
    }
    final nav = _navigatorState;
    if (nav == null) {
      NavLog.w('Router: navigateTo deferred (${page.name})');
      _pendingNavigation = page;
      return;
    }
    if (nav.current == page) {
      NavLog.d('Router: navigateTo skipped, already on ${page.name}');
      return;
    }
    NavLog.d('Router: navigateTo ${page.name}');
    nav.push(page);
  }

  /// Replace the entire stack from anywhere.
  void replaceAll(AppPage page) {
    final nav = _navigatorState;
    if (nav == null) {
      NavLog.w('Router: replaceAll deferred (${page.name})');
      _pendingNavigation = page;
      return;
    }
    NavLog.d('Router: replaceAll ${page.name}');
    nav.replaceAll(page);
  }

  /// Replace the entire stack with multiple pages from anywhere.
  void replaceAllWith(AppNavigationState pages) {
    final nav = _navigatorState;
    if (nav == null) {
      NavLog.w('Router: replaceAllWith deferred');
      if (pages.isNotEmpty) _pendingNavigation = pages.last;
      return;
    }
    nav.replaceAllWith(pages);
  }

  /// The current page stack, or empty if navigator isn't ready yet.
  AppNavigationState get currentPages => _navigatorState?.pages.toList() ?? [];

  // ---------------------------------------------------------------------------
  // RouterDelegate overrides
  // ---------------------------------------------------------------------------

  @override
  AppNavigationState? get currentConfiguration =>
      _navigatorState?.pages.toList();

  @override
  Future<void> setNewRoutePath(AppNavigationState configuration) async {
    if (configuration.isEmpty) return;

    // If the parsed route is just [Splash], the parser intentionally
    // returned a no-op (transitional path or `/`). Ignore it.
    if (configuration.length == 1 && configuration.first is SplashPage) return;

    // Don't apply deep links until the app has moved past splash.
    // The guard system handles initial routing (splash → home/onboarding).
    if (!_initialized) {
      NavLog.d(
        'Router: deep link deferred until init (${configuration.last.name})',
      );
      _pendingNavigation = configuration.last;
      return;
    }

    final nav = _navigatorState;
    if (nav == null) {
      _pendingNavigation = configuration.last;
      return;
    }

    NavLog.d(
      'Router: deep link -> ${configuration.map((p) => p.name).toList()}',
    );
    nav.replaceAllWith(configuration);
  }

  @override
  Future<bool> popRoute() async {
    final nav = _navigatorState;
    if (nav == null) return false;
    if (nav.canPop) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        return navigator.maybePop();
      }
      nav.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigator(
      pages: initialPages,
      navigatorKey: navigatorKey,
      guards: guards,
      refreshListenable: refreshListenable,
      observers: observers,
      builder: (context, navigatorState, child) {
        if (_navigatorState != navigatorState) {
          _navigatorState = navigatorState;
          _flushPending();
        }
        return child;
      },
      onStateChanged: () {
        // Track when the app moves past splash and auth pages.
        final nav = _navigatorState;
        if (!_initialized && nav != null && nav.current is! SplashPage) {
          _initialized = true;
          NavLog.d('Router: initialized');
          _flushPending();
        }
        // Notify the Router framework that configuration changed (URL sync).
        notifyListeners();
      },
    );
  }

  void _flushPending() {
    final pending = _pendingNavigation;
    if (pending == null) return;
    _pendingNavigation = null;
    final nav = _navigatorState;
    if (nav == null) return;
    NavLog.d('Router: flushing pending -> ${pending.name}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nav.push(pending);
    });
  }
}
