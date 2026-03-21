part of 'friends_controller.dart';

sealed class FriendState extends BaseState {
  const FriendState({required super.message});

  const factory FriendState.idle({required String message}) = FriendStateIdle;
  const factory FriendState.processing({required String message}) =
      FriendStateProcessing;
  const factory FriendState.failed({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = FriendStateFailed;

  @override
  bool get isIdle => this is FriendStateIdle;

  @override
  bool get isProcessing => this is FriendStateProcessing;

  @override
  bool get isFailed => this is FriendStateFailed;

  @override
  Object? get error => switch (this) {
    FriendStateFailed(:final message) => message,
    _ => null,
  };

  FriendState copyWith({String? message});
}

final class FriendStateIdle extends FriendState {
  const FriendStateIdle({required super.message});

  @override
  String get type => 'idle';

  @override
  FriendState copyWith({String? message}) {
    return FriendStateIdle(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FriendStateIdle && message == other.message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class FriendStateProcessing extends FriendState {
  const FriendStateProcessing({required super.message});

  @override
  String get type => 'processing';

  @override
  FriendState copyWith({String? message}) {
    return FriendStateProcessing(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FriendStateProcessing && message == other.message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class FriendStateFailed extends FriendState {
  @override
  final Object? error;
  final StackTrace? stackTrace;

  const FriendStateFailed({
    required super.message,
    this.error,
    this.stackTrace,
  });

  @override
  String get type => 'failed';

  @override
  FriendState copyWith({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return FriendStateFailed(
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FriendStateFailed &&
            message == other.message &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, error);
}
