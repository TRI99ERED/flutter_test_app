part of 'app_controller.dart';

sealed class AppState extends BaseState {
  final UserEntity user;

  const AppState({required super.message, required this.user});

  const factory AppState.idle({
    required String message,
    required UserEntity user,
  }) = AppStateIdle;
  const factory AppState.processing({
    required String message,
    required UserEntity user,
  }) = AppStateProcessing;
  const factory AppState.failed({
    required String message,
    required UserEntity user,
    Object? error,
    StackTrace? stackTrace,
  }) = AppStateFailed;

  @override
  bool get isIdle => this is AppStateIdle;

  @override
  bool get isProcessing => this is AppStateProcessing;

  @override
  bool get isFailed => this is AppStateFailed;

  bool get isAuthorized => user is AuthorizedUser;

  @override
  Object? get error => switch (this) {
    AppStateFailed(:final message) => message,
    _ => null,
  };

  AppState copyWith({String? message, UserEntity? user});
}

final class AppStateIdle extends AppState {
  const AppStateIdle({required super.message, required super.user});

  @override
  String get type => 'idle';

  @override
  AppState copyWith({String? message, UserEntity? user}) {
    return AppStateIdle(
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppStateIdle && message == other.message && user == other.user;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, user);
}

final class AppStateProcessing extends AppState {
  const AppStateProcessing({required super.message, required super.user});

  @override
  String get type => 'processing';

  @override
  AppState copyWith({String? message, UserEntity? user}) {
    return AppStateProcessing(
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppStateProcessing &&
            message == other.message &&
            user == other.user;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, user);
}

final class AppStateFailed extends AppState {
  @override
  final Object? error;
  final StackTrace? stackTrace;

  const AppStateFailed({
    required super.message,
    required super.user,
    this.error,
    this.stackTrace,
  });

  @override
  String get type => 'failed';

  @override
  AppState copyWith({
    String? message,
    UserEntity? user,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return AppStateFailed(
      message: message ?? this.message,
      user: user ?? this.user,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppStateFailed &&
            message == other.message &&
            user == other.user &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, user, error);
}
