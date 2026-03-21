import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/src/router/app_page.dart';
import 'package:test_app/src/router/nav_log.dart';

/// Type alias for guard functions used by [AppNavigator].
typedef AppNavigationGuard =
    AppNavigationState Function(BuildContext context, AppNavigationState state);

/// A declarative navigator driven by a list of [AppPage] instances.
///
/// Supports two modes:
///
/// **Uncontrolled** — manages its own page stack internally, starting
/// from [pages]. Mutate via [AppNavigatorState] methods obtained
/// through [AppNavigator.of].
///
/// **Controlled** — syncs with an external [ValueNotifier]. All
/// mutations go through [change]; the notifier is kept in sync.
///
/// In both modes, [guards] are applied in order on every state change and can
/// rewrite or reject the proposed stack.
/// Signature for a builder that wraps the navigator output.
/// Receives the [AppNavigatorState] so callers (like [AppRouterDelegate])
/// can capture a reference without global keys.
typedef AppNavigatorBuilder =
    Widget Function(
      BuildContext context,
      AppNavigatorState navigatorState,
      Widget child,
    );

class AppNavigator extends StatefulWidget {
  const AppNavigator({
    super.key,
    required this.pages,
    required this.navigatorKey,
    this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.refreshListenable,
    this.onDidRemovePage,
    this.builder,
    this.onStateChanged,
  }) : assert(pages.length > 0, 'pages must not be empty');

  final GlobalKey<NavigatorState> navigatorKey;

  /// Retrieve the nearest [AppNavigatorState] from the widget tree.
  static AppNavigatorState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppNavigatorState>();
    assert(state != null, 'No AppNavigator found in the widget tree');
    return state!;
  }

  /// Retrieve the nearest [AppNavigatorState], or `null` if absent.
  static AppNavigatorState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AppNavigatorState>();
  }

  /// The initial pages for the navigator.
  ///
  /// In uncontrolled mode, these are the starting pages. In controlled mode,
  /// the controller's value is used instead.
  final AppNavigationState pages;

  /// Optional controller for managing navigation state externally.
  ///
  /// When provided, the navigator syncs with this [ValueNotifier]. External
  /// writes to the notifier are applied after passing through guards.
  final ValueNotifier<AppNavigationState>? controller;

  /// Guards that validate and modify navigation state changes.
  ///
  /// Each guard function receives the current context and the proposed new state,
  /// and returns a modified state. Guards are applied in order, and each guard
  /// receives the result from the previous guard.
  final List<AppNavigationGuard> guards;

  /// Observers attached to the underlying Navigator.
  final List<NavigatorObserver> observers;

  /// The transition delegate that controls how page transitions are handled.
  final TransitionDelegate<Object?> transitionDelegate;

  /// A listenable that triggers page revalidation when it changes.
  ///
  /// When this listenable notifies its listeners, the navigator will reapply
  /// all guards to the current state and update if necessary.
  final Listenable? refreshListenable;

  /// Called when a page is removed via the system back button or gesture.
  ///
  /// If not provided, the default behavior removes the page from the stack.
  final void Function(Page<Object?> page)? onDidRemovePage;

  /// Optional builder that wraps the navigator output.
  /// Use this to capture the [AppNavigatorState] reference.
  final AppNavigatorBuilder? builder;

  /// Called whenever the page stack changes.
  /// Use this to notify external listeners (e.g. [RouterDelegate]).
  final VoidCallback? onStateChanged;

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

class AppNavigatorState extends State<AppNavigator> {
  late AppNavigationState _state;

  /// The current page stack (read-only view).
  UnmodifiableListView<AppPage> get pages => UnmodifiableListView(_state);

  /// The page currently on top of the stack.
  AppPage get current => _state.last;

  /// Whether there is more than one page in the stack.
  bool get canPop => _state.length > 1;

  /// Whether the navigator is using an external controller.
  bool get isControlled => widget.controller != null;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _state = isControlled
        ? widget.controller!.value.toList()
        : widget.pages.toList();

    NavLog.d('Created ${_stackLabel(_state)}');

    widget.controller?.addListener(_onControllerChanged);
    widget.refreshListenable?.addListener(_onRefresh);

    // Apply guards immediately so we don't sit on stale initial pages
    // (e.g. SplashPage when auth state is already known).
    final guarded = _applyGuards(context, _state.toList());
    if (guarded.isNotEmpty && !listEquals(guarded, _state)) {
      NavLog.d(
        'Guard redirected ${_stackLabel(_state)} -> ${_stackLabel(guarded)}',
      );
      _state = guarded;
    }
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (isControlled) {
        _applyState(widget.controller!.value);
      }
    }

    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable?.removeListener(_onRefresh);
      widget.refreshListenable?.addListener(_onRefresh);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    widget.refreshListenable?.removeListener(_onRefresh);
    NavLog.d('Disposed (was ${_stackLabel(_state)})');
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Public API — all built on top of [change]
  // ---------------------------------------------------------------------------

  /// The core mutation method. Apply a transformation to the current page stack.
  ///
  /// [fn] receives the current state and must return the new state.
  /// Guards are applied to the result before committing.
  /// All other navigation methods delegate to this.
  void change(AppNavigationState Function(AppNavigationState pages) fn) {
    final prev = _state.toList();
    var next = fn(prev);

    if (next.isEmpty) {
      NavLog.w('Blocked: change would empty the stack');
      return;
    }

    if (!mounted) return;
    final ctx = context;

    final beforeGuards = next.length;
    next = _applyGuards(ctx, next);

    if (next.isEmpty) {
      NavLog.w('Blocked: guards emptied the stack', {
        'pagesBeforeGuards': beforeGuards,
      });
      return;
    }

    if (listEquals(next, _state)) return;

    NavLog.d('${_stackLabel(prev)} -> ${_stackLabel(next)}');

    _state = next;
    _syncToController();
    widget.onStateChanged?.call();
    setState(() {});
  }

  /// Push a page onto the stack.
  void push(AppPage page) {
    change((pages) => [...pages, page]);
  }

  /// Pop the top page. Returns `false` if only one page remains.
  bool pop() {
    if (!canPop) {
      NavLog.w('Cannot pop: ${_state.last.name} is the only page');
      return false;
    }
    change((pages) => pages.sublist(0, pages.length - 1));
    return true;
  }

  /// Replace the top page with [page].
  void replace(AppPage page) {
    change((pages) => [...pages.sublist(0, pages.length - 1), page]);
  }

  /// Replace the entire stack with a single page.
  void replaceAll(AppPage page) {
    change((_) => [page]);
  }

  /// Replace the entire stack with multiple pages.
  void replaceAllWith(AppNavigationState pages) {
    assert(pages.isNotEmpty, 'Cannot set an empty page stack');
    change((_) => pages);
  }

  /// Push a page, or if a page of the same type already exists in the stack,
  /// remove everything above it and replace it with [page].
  void pushOrBringToTop(AppPage page) {
    change((pages) {
      final idx = pages.indexWhere((p) => p.runtimeType == page.runtimeType);
      if (idx >= 0) {
        return [...pages.sublist(0, idx), page];
      }
      return [...pages, page];
    });
  }

  /// Pop pages until [predicate] returns `true` for the top page.
  /// The matching page is kept.
  void popUntil(bool Function(AppPage page) predicate) {
    change((pages) {
      var stack = pages.toList();
      while (stack.length > 1 && !predicate(stack.last)) {
        stack = stack.sublist(0, stack.length - 1);
      }
      return stack;
    });
  }

  /// Remove all pages matching [predicate] from the stack.
  void removeWhere(bool Function(AppPage page) predicate) {
    change((pages) {
      final next = pages.where((p) => !predicate(p)).toList();
      return next.isEmpty ? pages : next;
    });
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    _applyState(widget.controller!.value);
  }

  void _onRefresh() {
    if (!mounted) return;
    final next = _applyGuards(context, _state.toList());
    if (next.isEmpty) {
      NavLog.w('Refresh blocked: guards emptied the stack');
      return;
    }
    if (listEquals(next, _state)) return;
    NavLog.d('Refresh: ${_stackLabel(_state)} -> ${_stackLabel(next)}');
    _state = next;
    _syncToController();
    widget.onStateChanged?.call();
    setState(() {});
  }

  void _applyState(AppNavigationState proposed) {
    if (!mounted) return;
    var next = proposed.toList();

    if (next.isEmpty) {
      NavLog.w('Blocked: controller sent empty stack');
      return;
    }

    next = _applyGuards(context, next);

    if (next.isEmpty) {
      NavLog.w('Blocked: guards emptied controller stack');
      return;
    }

    if (listEquals(next, _state)) return;

    NavLog.d('Controller: ${_stackLabel(_state)} -> ${_stackLabel(next)}');

    _state = next;
    setState(() {});
  }

  AppNavigationState _applyGuards(BuildContext ctx, AppNavigationState state) {
    return widget.guards.fold(state, (s, guard) => guard(ctx, s));
  }

  /// Sync state to controller without triggering another listener cycle.
  void _syncToController() {
    final controller = widget.controller;
    if (controller == null) return;
    if (listEquals(controller.value, _state)) return;

    controller.removeListener(_onControllerChanged);
    controller.value = _state;
    controller.addListener(_onControllerChanged);
  }

  void _handleDidRemovePage(Page<Object?> page) {
    if (widget.onDidRemovePage != null) {
      widget.onDidRemovePage!(page);
      return;
    }

    final index = _state.indexWhere((p) => p.key == page.key);
    if (index < 0) {
      NavLog.w('System removed unknown page: ${page.name}');
      return;
    }

    if (_state.length <= 1) {
      NavLog.w('Cannot pop: ${_state.last.name} is the only page');
      return;
    }

    final removed = _state[index];
    _state = [..._state.sublist(0, index), ..._state.sublist(index + 1)];

    NavLog.d('Back: removed ${removed.name} -> ${_stackLabel(_state)}');

    _syncToController();
    widget.onStateChanged?.call();
    widget.onDidRemovePage?.call(page);
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _stackLabel(List<AppPage> pages) {
    return '[${pages.map((p) => p.name).join(' > ')}]';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Widget child = Navigator(
      key: widget.navigatorKey,
      pages: _state,
      onDidRemovePage: _handleDidRemovePage,
      transitionDelegate: widget.transitionDelegate,
      observers: widget.observers,
    );

    if (widget.builder != null) {
      child = widget.builder!(context, this, child);
    }

    // PopScope fallback for when AppNavigator is used without a Router.
    // When used inside Router, popRoute() handles back navigation instead.
    if (Router.maybeOf(context) == null) {
      child = PopScope(
        canPop: !canPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) pop();
        },
        child: child,
      );
    }

    return child;
  }
}
