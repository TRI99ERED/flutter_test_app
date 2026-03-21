part of 'chat_controller.dart';

sealed class ChatState extends BaseState {
  const ChatState({required super.message});

  const factory ChatState.idle({required String message}) = ChatStateIdle;
  const factory ChatState.processing({required String message}) =
      ChatStateProcessing;
  const factory ChatState.failed({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) = ChatStateFailed;

  @override
  bool get isIdle => this is ChatStateIdle;

  @override
  bool get isProcessing => this is ChatStateProcessing;

  @override
  bool get isFailed => this is ChatStateFailed;

  @override
  Object? get error => switch (this) {
    ChatStateFailed(:final message) => message,
    _ => null,
  };

  ChatState copyWith({String? message});
}

final class ChatStateIdle extends ChatState {
  const ChatStateIdle({required super.message});

  @override
  String get type => 'idle';

  @override
  ChatState copyWith({String? message}) {
    return ChatStateIdle(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatStateIdle && message == other.message;
  }

  @override
  int get hashCode => message.hashCode;
}

final class ChatStateProcessing extends ChatState {
  const ChatStateProcessing({required super.message});

  @override
  String get type => 'processing';

  @override
  ChatState copyWith({String? message}) {
    return ChatStateProcessing(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatStateProcessing && message == other.message;
  }

  @override
  int get hashCode => message.hashCode;
}

final class ChatStateFailed extends ChatState {
  @override
  final Object error;
  final StackTrace stackTrace;

  const ChatStateFailed({
    required super.message,
    required this.error,
    required this.stackTrace,
  });

  @override
  String get type => 'failed';

  @override
  ChatState copyWith({String? message}) {
    return ChatStateFailed(
      message: message ?? this.message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatStateFailed &&
            message == other.message &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
