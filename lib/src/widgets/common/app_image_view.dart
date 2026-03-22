import 'package:flutter/material.dart';

class AppImageView extends StatefulWidget {
  final String imageUrl;

  const AppImageView({super.key, required this.imageUrl});

  static void show(BuildContext context, {required String imageUrl}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      barrierDismissible: true,
      builder: (context) {
        return AppImageView(imageUrl: imageUrl);
      },
    );
  }

  @override
  State<AppImageView> createState() => _AppImageViewState();
}

class _AppImageViewState extends State<AppImageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldDismiss = _dragOffset.abs() > 100 || velocity.abs() > 500;

    if (shouldDismiss) {
      final dismissDirection = _dragOffset > 0
          ? const Offset(0, 1)
          : const Offset(0, -1);
      _offsetAnimation = Tween<Offset>(
        begin: Offset(0, _dragOffset / MediaQuery.of(context).size.height),
        end: dismissDirection,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward().then((_) {
        Navigator.of(context).pop();
      });
    } else {
      _offsetAnimation = Tween<Offset>(
        begin: Offset(0, _dragOffset / MediaQuery.of(context).size.height),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward().then((_) {
        _controller.reset();
        setState(() {
          _dragOffset = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedOffset = _dragOffset / MediaQuery.of(context).size.height;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _controller.isAnimating
              ? _offsetAnimation.value
              : Offset(0, normalizedOffset);
          final scale = _controller.isAnimating ? _scaleAnimation.value : 1.0;

          return SlideTransition(
            position: AlwaysStoppedAnimation(offset),
            child: ScaleTransition(
              scale: AlwaysStoppedAnimation(scale),
              child: child,
            ),
          );
        },
        child: Image.network(widget.imageUrl),
      ),
    );
  }
}
