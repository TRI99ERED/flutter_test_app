import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MySearchBar extends StatelessWidget {
  final String? text;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const MySearchBar({
    super.key,
    this.text,
    this.placeholder,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      initialValue: text,
      cursorColor: HighlightColor.darkest.color,
      style: TextStyle(
        color: DarkColor.darkest.color,
        fontSize: bMSize,
        fontWeight: bMWeight,
      ),
      decoration: InputDecoration(
        hintText: placeholder ?? 'Search',
        hintStyle: TextStyle(
          color: DarkColor.lightest.color,
          fontSize: bMSize,
          fontWeight: bMWeight,
        ),
        prefixIcon: Icon(
          AppIcons.search,
          color: DarkColor.dark.color,
          size: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: LightColor.light.color,
      ),
    );
  }
}
