import 'package:test_app/src/base_controller.dart';

sealed class AppState extends BaseState {
  final bool obscurePassword;

  const AppState({required super.message, required this.obscurePassword});

  const factory AppState.idle({
    required String message,
    required bool obscurePassword,
  }) = AppStateIdle;
  const factory AppState.processing({
    required String message,
    required bool obscurePassword,
  }) = AppStateProcessing;
  const factory AppState.failed({
    required String message,
    required bool obscurePassword,
    Object? error,
    StackTrace? stackTrace,
  }) = AppStateFailed;

  @override
  bool get isIdle => this is AppStateIdle;

  @override
  bool get isProcessing => this is AppStateProcessing;

  @override
  bool get isFailed => this is AppStateFailed;

  @override
  Object? get error => switch (this) {
    AppStateFailed(:final message) => message,
    _ => null,
  };

  AppState copyWith({bool? obscurePassword, String? message});
}

final class AppStateIdle extends AppState {
  const AppStateIdle({required super.message, required super.obscurePassword});

  @override
  String get type => 'idle';

  @override
  AppState copyWith({String? message, bool? obscurePassword}) {
    return AppStateIdle(
      message: message ?? this.message,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AppStateIdle;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class AppStateProcessing extends AppState {
  const AppStateProcessing({
    required super.message,
    required super.obscurePassword,
  });

  @override
  String get type => 'processing';

  @override
  AppState copyWith({String? message, bool? obscurePassword}) {
    return AppStateProcessing(
      message: message ?? this.message,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AppStateProcessing;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class AppStateFailed extends AppState {
  @override
  final Object? error;
  final StackTrace? stackTrace;

  const AppStateFailed({
    required super.message,
    required super.obscurePassword,
    this.error,
    this.stackTrace,
  });

  @override
  String get type => 'failed';

  @override
  AppState copyWith({
    String? message,
    bool? obscurePassword,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppStateFailed(
      message: message ?? this.message,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppStateFailed && error == other.error;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, error);
}

final class AppController extends BaseController<AppState> {
  AppController()
    : super(
        state: const AppState.idle(
          message: 'initialized',
          obscurePassword: true,
        ),
        name: 'AppController',
      ) {
    // NOTE: You can make actions here
  }

  Future<void> forgotPassword() async =>
      await serialExecutor.synchronized(() async {
        try {
          setState(state.copyWith(message: 'Processing forgot password...'));
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Forgot password error',
              obscurePassword: state.obscurePassword,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          onError(error, stackTrace);
        } finally {
          setState(
            AppState.idle(
              message: state.message,
              obscurePassword: state.obscurePassword,
            ),
          );
        }
      });

  Future<void> login() async => await serialExecutor.synchronized(() async {
    try {
      setState(state.copyWith(message: 'Processing login...'));
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Login error',
          obscurePassword: state.obscurePassword,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      onError(error, stackTrace);
    } finally {
      setState(
        AppState.idle(
          message: state.message,
          obscurePassword: state.obscurePassword,
        ),
      );
    }
  });

  Future<void> register() async => await serialExecutor.synchronized(() async {
    try {
      setState(state.copyWith(message: 'Processing register...'));
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Register error',
          obscurePassword: state.obscurePassword,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      onError(error, stackTrace);
    } finally {
      setState(
        AppState.idle(
          message: state.message,
          obscurePassword: state.obscurePassword,
        ),
      );
    }
  });

  Future<void> toggleObscurePassword() async =>
      await serialExecutor.synchronized(() async {
        try {
          setState(
            state.copyWith(
              obscurePassword: !state.obscurePassword,
              message: 'Toggling password visibility...',
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Toggle password visibility error',
              obscurePassword: state.obscurePassword,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          onError(error, stackTrace);
        } finally {
          setState(
            AppState.idle(
              message: state.message,
              obscurePassword: state.obscurePassword,
            ),
          );
        }
      });

  @override
  void dispose() {
    super.dispose();
  }
}
