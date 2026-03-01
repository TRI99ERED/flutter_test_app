import 'package:flutter/material.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';

class ControllerConsumer<S extends BaseState> extends StatefulWidget {
  final BaseController<S> controller;
  final Widget Function(BuildContext context, S current) builder;
  final void Function(BuildContext context, S previous, S current) listener;
  final bool Function(S previous, S current)? buildWhen;
  final bool Function(S previous, S current)? listenWhen;

  const ControllerConsumer({
    super.key,
    required this.controller,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  @override
  State<ControllerConsumer<S>> createState() => _ControllerConsumerState<S>();
}

class _ControllerConsumerState<S extends BaseState>
    extends State<ControllerConsumer<S>> {
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

    if (widget.buildWhen?.call(_previousState, current) ?? true) {
      setState(() {});
    }

    _previousState = current;
  }

  @override
  void didUpdateWidget(covariant ControllerConsumer<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onStateChange);
      _previousState = widget.controller.state;
      widget.controller.addListener(_onStateChange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.controller.state);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }
}
