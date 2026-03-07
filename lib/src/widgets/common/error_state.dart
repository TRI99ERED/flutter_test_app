import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class ErrorState extends StatelessWidget {
  final String message;

  const ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SelectableText(
        message,
        style: TextStyle(
          fontSize: h4Size,
          fontWeight: h4Weight,
          color: ErrorColor.dark.color,
        ),
      ),
    );
  }
}
