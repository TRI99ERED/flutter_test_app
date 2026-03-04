import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 0, color: LightColor.dark.color);
  }
}

