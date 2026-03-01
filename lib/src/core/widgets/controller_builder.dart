import 'package:flutter/material.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';

class ControllerBuilder<S extends BaseState> extends StatefulWidget {
  final BaseController<S> controller;
  final Widget Function(BuildContext context, S state) builder;
  final bool Function(S previous, S current)? buildWhen;

  const ControllerBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.buildWhen,
  });

  @override
  State<ControllerBuilder<S>> createState() => _ControllerBuilderState<S>();
}

class _ControllerBuilderState<S extends BaseState>
    extends State<ControllerBuilder<S>> {
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

    if (widget.buildWhen?.call(_previousState, current) ?? true) {
      setState(() {});
    }

    _previousState = current;
  }

  @override
  void didUpdateWidget(covariant ControllerBuilder<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onStateChange);
      _previousState = widget.controller.state;
      widget.controller.addListener(_onStateChange);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.controller.state);

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }
}
