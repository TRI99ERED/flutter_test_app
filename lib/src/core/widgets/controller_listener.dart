import 'package:flutter/material.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';

class ControllerListener<S extends BaseState> extends StatefulWidget {
  final BaseController<S> controller;
  final void Function(BuildContext context, S previous, S current) listener;
  final Widget child;
  final bool Function(S previous, S current)? listenWhen;

  const ControllerListener({
    super.key,
    required this.controller,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  @override
  State<ControllerListener<S>> createState() => _ControllerListenerState<S>();
}

class _ControllerListenerState<S extends BaseState>
    extends State<ControllerListener<S>> {
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _previousState = widget.controller.state;
    widget.controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (!mounted) return;

    final current = widget.controller.state;

    if (widget.listenWhen?.call(_previousState, current) ?? true) {
      widget.listener(context, _previousState, current);
    }

    _previousState = current;
  }

  @override
  void didUpdateWidget(covariant ControllerListener<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onStateChange);
      _previousState = widget.controller.state;
      widget.controller.addListener(_onStateChange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }
}
