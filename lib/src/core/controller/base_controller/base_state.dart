part of 'base_controller.dart';

abstract base class BaseState {
  abstract final String type;
  @nonVirtual
  final String message;

  const BaseState({required this.message});

  factory BaseState.initial({required String? message}) =>
      BaseStateIdle(message: message ?? 'initialisation');
  const factory BaseState.idle({required String message}) = BaseStateIdle;
  const factory BaseState.processing({required String message}) =
      BaseStateProcessing;
  const factory BaseState.failed({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = BaseStateFailed;

  bool get isIdle => this is BaseStateIdle;
  bool get isProcessing => this is BaseStateProcessing;
  bool get isFailed => this is BaseStateFailed;
  Object? get error => switch (this) {
    BaseStateFailed(:final error) => error,
    _ => null,
  };

  T map<T>({
    required T Function(BaseState) idle,
    required T Function(BaseState) processing,
    required T Function(BaseState) failed,
    T Function(BaseState)? orElse,
  }) {
    if (this is BaseStateIdle) {
      return idle(this);
    } else if (this is BaseStateProcessing) {
      return processing(this);
    } else if (this is BaseStateFailed) {
      return failed(this);
    } else if (orElse != null) {
      return orElse(this);
    } else {
      throw StateError(
        'No handler for state $runtimeType.'
        'Override map() on your sealed class or provide orElse',
      );
    }
  }

  T? maybeMap<T>({
    T Function(BaseState)? idle,
    T Function(BaseState)? processing,
    T Function(BaseState)? failed,
  }) {
    if (this is BaseStateIdle) {
      return idle?.call(this);
    } else if (this is BaseStateProcessing) {
      return processing?.call(this);
    } else if (this is BaseStateFailed) {
      return failed?.call(this);
    }
    return null;
  }

  T mapOrElse<T>({
    T Function(BaseState)? idle,
    T Function(BaseState)? processing,
    T Function(BaseState)? failed,
    required T Function(BaseState) orElse,
  }) {
    if (this is BaseStateIdle) {
      return idle?.call(this) ?? orElse(this);
    } else if (this is BaseStateProcessing) {
      return processing?.call(this) ?? orElse(this);
    } else if (this is BaseStateFailed) {
      return failed?.call(this) ?? orElse(this);
    }
    return orElse(this);
  }

  @override
  String toString() {
    return 'BaseState.$type(message: $message)';
  }
}

final class BaseStateIdle extends BaseState {
  const BaseStateIdle({required super.message});

  @override
  String get type => 'idle';

  @override
  String toString() => 'BaseState.idle(message: $message)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BaseStateIdle && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => message.hashCode;
}

final class BaseStateProcessing extends BaseState {
  const BaseStateProcessing({required super.message});

  @override
  String get type => 'processing';

  @override
  String toString() => 'BaseState.processing(message: $message)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BaseStateProcessing && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => message.hashCode;
}

final class BaseStateFailed extends BaseState {
  const BaseStateFailed({required super.message, this.error, this.stackTrace});

  @override
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get type => 'failed';

  @override
  String toString() =>
      'BaseState.failed(message: $message, $error, $stackTrace)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BaseStateFailed &&
            runtimeType == other.runtimeType &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
