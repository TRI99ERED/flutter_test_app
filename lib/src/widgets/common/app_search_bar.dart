import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppSearchBar extends StatefulWidget {
  final String? text;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.text,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.controller,
  }) : assert(
         controller == null || text == null,
         'controller and text cannot both be provided',
       );

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    if (widget.text != null) {
      _effectiveController.text = widget.text!;
    }
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.text != oldWidget.text) {
      _internalController.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _effectiveController,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: HighlightColor.darkest.color,
      style: TextStyle(
        color: DarkColor.darkest.color,
        fontSize: bMSize,
        fontWeight: bMWeight,
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder ?? 'Search',
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
