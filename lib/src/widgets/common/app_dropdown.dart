import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppDropdown extends StatefulWidget {
  final List<DropdownMenuEntry<String>> items;
  final String? title;
  final bool enabled;
  final int selectedIndex;
  final String? placeholder;
  final String? text;
  final String? errorText;
  final String? supportText;
  final ValueChanged<String?>? onSelected;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? controller;

  const AppDropdown({
    super.key,
    required this.items,
    this.title,
    this.enabled = true,
    this.selectedIndex = 0,
    this.placeholder,
    this.text,
    this.errorText,
    this.supportText,
    this.onSelected,
    this.validator,
    this.autovalidateMode,
    this.controller,
  }) : assert(
         controller == null || text == null,
         'controller and text cannot both be provided',
       );

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  late int _selectedIndex;
  String? _validatorErrorText;
  bool _isSelected = false;
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  String _searchQuery = '';
  late TextEditingController _internalController;

  String? _getDisplayErrorText() {
    final customError = widget.errorText;
    if (customError != null && customError.isNotEmpty) {
      return customError;
    }
    return _validatorErrorText;
  }

  List<DropdownMenuEntry<String>> _getFilteredItems() {
    if (_searchQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.value.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _rebuildOverlay() {
    if (_isSelected) {
      _hideOverlay();
      _showOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _selectedIndex = widget.selectedIndex;
    _internalController = TextEditingController();

    final controller = widget.controller ?? _internalController;
    if (widget.text != null) {
      controller.text = widget.text!;
      _searchQuery = widget.text!;

      _validatorErrorText = widget.validator?.call(widget.text!);
    }
  }

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void didUpdateWidget(AppDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && widget.text != oldWidget.text) {
      _internalController.text = widget.text ?? '';
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      return;
    }

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    const maxOverlayHeight = 250.0;
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final spaceAbove = offset.dy;

    final showAbove = spaceBelow < maxOverlayHeight && spaceAbove > spaceBelow;
    final overlayOffset = showAbove
        ? Offset(0, -(maxOverlayHeight + 4))
        : Offset(0, size.height + 4);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _hideOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                borderRadius: BorderRadius.zero,
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  decoration: BoxDecoration(
                    color: LightColor.lightest.color,
                    borderRadius: BorderRadius.zero,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 250.0,
                    maxWidth: size.width,
                  ),
                  child: _getFilteredItems().isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: spacing8,
                              horizontal: spacing16,
                            ),
                            child: Text(
                              'No options found',
                              style: TextStyle(
                                fontSize: bSSize,
                                fontWeight: bSWeight,
                                color: DarkColor.light.color,
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.all(spacing8),
                          shrinkWrap: true,
                          children: _getFilteredItems().map((entry) {
                            final isSelected =
                                widget.items.indexOf(entry) == _selectedIndex;
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: spacing2),
                              child: _AppDropdownOption(
                                value: entry.label,
                                selected: isSelected,
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = widget.items.indexOf(
                                      entry,
                                    );
                                    _searchQuery = '';
                                  });
                                  _hideOverlay();
                                  _focusNode.unfocus();

                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      _effectiveController.clear();
                                      widget.onSelected?.call(entry.value);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isSelected = true;
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isSelected = false;
      });
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayErrorText = _getDisplayErrorText();

    return Stack(
      children: [
        if (_isSelected)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _hideOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            if (widget.title != null)
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: h5Size,
                  fontWeight: h5Weight,
                  color: widget.enabled
                      ? DarkColor.darkest.color
                      : DarkColor.lightest.color,
                ),
              ),
            CompositedTransformTarget(
              link: _layerLink,
              child: TextFormField(
                key: _textFieldKey,
                focusNode: _focusNode,
                controller: _effectiveController,
                onTap: widget.enabled ? () => _showOverlay() : null,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _rebuildOverlay();
                  final nextError = widget.validator?.call(value);
                  if (nextError != _validatorErrorText) {
                    setState(() {
                      _validatorErrorText = nextError;
                    });
                  }
                },
                validator: (value) => widget.validator?.call(value),
                autovalidateMode: widget.autovalidateMode,
                enabled: widget.enabled,
                cursorColor: HighlightColor.darkest.color,
                cursorErrorColor: ErrorColor.dark.color,
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: widget.enabled
                      ? DarkColor.darkest.color
                      : DarkColor.lightest.color,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    fontSize: bMSize,
                    fontWeight: bMWeight,
                    color: DarkColor.lightest.color,
                  ),
                  errorText: displayErrorText == null ? null : '',
                  errorStyle: TextStyle(fontSize: 0, height: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: LightColor.darkest.color,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: HighlightColor.darkest.color,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: ErrorColor.medium.color,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: ErrorColor.dark.color,
                      width: 2,
                    ),
                  ),
                  fillColor: LightColor.darkest.color,
                  filled: !widget.enabled,
                  suffixIcon: Icon(
                    _isSelected ? AppIcons.arrowUp : AppIcons.arrowDown,
                    size: 12,
                    color: DarkColor.lightest.color,
                  ),
                ),
              ),
            ),
            if (displayErrorText != null && displayErrorText.isNotEmpty)
              Text(
                displayErrorText,
                style: TextStyle(
                  fontSize: bSSize,
                  fontWeight: bSWeight,
                  color: ErrorColor.dark.color,
                ),
              ),
            if (widget.supportText != null &&
                (displayErrorText == null || displayErrorText.isEmpty))
              Text(
                widget.supportText!,
                style: TextStyle(
                  fontSize: bSSize,
                  fontWeight: bSWeight,
                  color: DarkColor.lightest.color,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AppDropdownOption extends StatelessWidget {
  final String _value;
  final VoidCallback? _onPressed;
  final bool _selected;

  const _AppDropdownOption({
    required String value,
    void Function()? onPressed,
    bool selected = false,
  }) : _selected = selected,
       _value = value,
       _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      style: TextButton.styleFrom(
        backgroundColor: _selected ? LightColor.light.color : null,
        foregroundColor: _selected
            ? DarkColor.darkest.color
            : DarkColor.light.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(_value),
    );
  }
}
