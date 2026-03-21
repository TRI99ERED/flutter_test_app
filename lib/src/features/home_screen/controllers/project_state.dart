part of 'project_controller.dart';

sealed class ProjectState extends BaseState {
  const ProjectState({required super.message});

  const factory ProjectState.idle({required String message}) = ProjectStateIdle;
  const factory ProjectState.processing({required String message}) =
      ProjectStateProcessing;
  const factory ProjectState.failed({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ProjectStateFailed;

  @override
  bool get isIdle => this is ProjectStateIdle;

  @override
  bool get isProcessing => this is ProjectStateProcessing;

  @override
  bool get isFailed => this is ProjectStateFailed;

  @override
  Object? get error => switch (this) {
    ProjectStateFailed(:final message) => message,
    _ => null,
  };

  ProjectState copyWith({String? message});
}

final class ProjectStateIdle extends ProjectState {
  const ProjectStateIdle({required super.message});

  @override
  String get type => 'idle';

  @override
  ProjectState copyWith({String? message}) {
    return ProjectStateIdle(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectStateIdle && message == other.message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class ProjectStateProcessing extends ProjectState {
  const ProjectStateProcessing({required super.message});

  @override
  String get type => 'processing';

  @override
  ProjectState copyWith({String? message}) {
    return ProjectStateProcessing(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectStateProcessing && message == other.message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class ProjectStateFailed extends ProjectState {
  @override
  final Object? error;
  final StackTrace? stackTrace;

  const ProjectStateFailed({
    required super.message,
    this.error,
    this.stackTrace,
  });

  @override
  String get type => 'failed';

  @override
  ProjectState copyWith({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return ProjectStateFailed(
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectStateFailed &&
            message == other.message &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, error);
}
