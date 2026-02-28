import 'dart:developer';

import 'package:test_app/src/base_controller.dart';

class ControllerObserver {
  ControllerObserver._();

  static final ControllerObserver _instance = ControllerObserver._();

  static ControllerObserver get instance => _instance;

  void Function(BaseController controller, Object error, StackTrace stackTrace)?
  onControllerError;

  void onCreate(BaseController controller, BaseState initialState) {
    log(
      'Controller ${controller.name} created with initial state: ${initialState.runtimeType}',
      name: 'ControllerObserver',
    );
  }

  void onStateChange(
    BaseController controller,
    BaseState previousState,
    BaseState newState,
  ) {
    if (previousState.hashCode == newState.hashCode && !newState.isFailed) {
      return;
    }

    log(
      'Controller ${controller.name} changed state from ${previousState.runtimeType} to ${newState.runtimeType}\n'
      'Message: ${newState.message}',
      name: 'ControllerObserver',
    );
  }

  void onError(BaseController controller, Object error, StackTrace stackTrace) {
    log(
      'Controller ${controller.name} encountered an error: $error',
      name: 'ControllerObserver',
      error: error,
      stackTrace: stackTrace,
    );
    onControllerError?.call(controller, error, stackTrace);
  }

  void onDispose(BaseController controller) {
    log(
      'Controller ${controller.name} is being disposed.',
      name: 'ControllerObserver',
    );
  }
}
