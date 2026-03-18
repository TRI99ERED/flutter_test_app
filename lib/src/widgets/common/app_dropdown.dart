import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppDropdown extends StatefulWidget {
  final List<DropdownMenuEntry<String>> items;
  final String? title;
  final bool enabled;
  final int selectedIndex;
  final String? placeholder;
  final String? text;
  final String? errorText;
  final String? supportText;
  final ValueChanged<(String, int)>? onSelected;
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
  late final ValueNotifier<int> _selectedIndex;
  late final ValueNotifier<String?> _validatorErrorText;
  late final ValueNotifier<bool> _isSelected;
  late final ValueNotifier<String> _searchQuery;
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  late TextEditingController _internalController;

  String? _getDisplayErrorText(String? validatorErrorText) {
    final customError = widget.errorText;
    if (customError != null && customError.isNotEmpty) {
      return customError;
    }
    return validatorErrorText;
  }

  List<DropdownMenuEntry<String>> _getFilteredItems(String searchQuery) {
    if (searchQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.value.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _rebuildOverlay() {
    if (_isSelected.value) {
      _hideOverlay();
      _showOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _selectedIndex = ValueNotifier<int>(widget.selectedIndex);
    _validatorErrorText = ValueNotifier<String?>(null);
    _isSelected = ValueNotifier<bool>(false);
    _searchQuery = ValueNotifier<String>('');
    _internalController = TextEditingController();

    final controller = widget.controller ?? _internalController;
    if (widget.text != null) {
      controller.text = widget.text!;
      _searchQuery.value = widget.text!;
      _validatorErrorText.value = widget.validator?.call(widget.text!);
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
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    borderRadius: BorderRadius.zero,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 250.0,
                    maxWidth: size.width,
                  ),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _searchQuery,
                    builder: (context, searchQuery, _) {
                      final filteredItems = _getFilteredItems(searchQuery);
                      return filteredItems.isEmpty
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
                                    color: Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.foregroundWeakColor,
                                  ),
                                ),
                              ),
                            )
                          : ValueListenableBuilder<int>(
                              valueListenable: _selectedIndex,
                              builder: (context, selectedIndex, _) {
                                return ListView(
                                  padding: EdgeInsets.all(spacing8),
                                  shrinkWrap: true,
                                  children: filteredItems.map((entry) {
                                    final isSelected =
                                        widget.items.indexOf(entry) ==
                                        selectedIndex;
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: spacing2,
                                      ),
                                      child: _AppDropdownOption(
                                        value: entry.label,
                                        selected: isSelected,
                                        onPressed: () {
                                          _selectedIndex.value = widget.items
                                              .indexOf(entry);
                                          _searchQuery.value = '';
                                          _hideOverlay();
                                          _focusNode.unfocus();

                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (mounted) {
                                                  _effectiveController.clear();
                                                  widget.onSelected?.call((
                                                    entry.value,
                                                    _selectedIndex.value,
                                                  ));
                                                  _effectiveController.text =
                                                      entry.label;
                                                }
                                              });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isSelected.value = true;
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      _isSelected.value = false;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.dispose();
    _selectedIndex.dispose();
    _validatorErrorText.dispose();
    _isSelected.dispose();
    _searchQuery.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSelected,
      builder: (context, isSelected, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _validatorErrorText,
          builder: (context, validatorErrorText, _) {
            final displayErrorText = _getDisplayErrorText(validatorErrorText);
            return Stack(
              children: [
                if (isSelected)
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
                              ? Theme.of(context)
                                    .extension<AppTheme>()
                                    ?.foregroundStrongestColor
                              : Theme.of(
                                  context,
                                ).extension<AppTheme>()?.foregroundWeakestColor,
                        ),
                      ),
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, searchQuery, _) {
                          return TextFormField(
                            key: _textFieldKey,
                            focusNode: _focusNode,
                            controller: _effectiveController,
                            onTap: widget.enabled ? () => _showOverlay() : null,
                            onChanged: (value) {
                              _searchQuery.value = value;
                              _rebuildOverlay();
                              final nextError = widget.validator?.call(value);
                              if (nextError != _validatorErrorText.value) {
                                _validatorErrorText.value = nextError;
                              }
                            },
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            validator: (value) => widget.validator?.call(value),
                            autovalidateMode: widget.autovalidateMode,
                            enabled: widget.enabled,
                            cursorColor: Theme.of(
                              context,
                            ).extension<AppTheme>()?.highlightDarkestColor,
                            cursorErrorColor: Theme.of(
                              context,
                            ).extension<AppTheme>()?.errorDarkColor,
                            style: TextStyle(
                              fontSize: bMSize,
                              fontWeight: bMWeight,
                              color: widget.enabled
                                  ? Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.foregroundStrongestColor
                                  : Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.foregroundWeakestColor,
                            ),
                            decoration: InputDecoration(
                              hintText: widget.placeholder,
                              hintStyle: TextStyle(
                                fontSize: bMSize,
                                fontWeight: bMWeight,
                                color: Theme.of(
                                  context,
                                ).extension<AppTheme>()?.foregroundWeakestColor,
                              ),
                              errorText: displayErrorText == null ? null : '',
                              errorStyle: TextStyle(fontSize: 0, height: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.backgroundWeakestColor ??
                                      Color(0xFFC5C6CC),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.highlightDarkestColor ??
                                      Color(0xFF006FFD),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.errorMediumColor ??
                                      Color(0xFFFF616D),
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).extension<AppTheme>()?.errorDarkColor ??
                                      Color(0xFFED3241),
                                  width: 2,
                                ),
                              ),
                              fillColor: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundWeakestColor,
                              filled: !widget.enabled,
                              suffixIcon: Icon(
                                isSelected
                                    ? AppIcons.arrowUp
                                    : AppIcons.arrowDown,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).extension<AppTheme>()?.foregroundWeakestColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (displayErrorText != null && displayErrorText.isNotEmpty)
                      Text(
                        displayErrorText,
                        style: TextStyle(
                          fontSize: bSSize,
                          fontWeight: bSWeight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.errorDarkColor,
                        ),
                      ),
                    if (widget.supportText != null &&
                        (displayErrorText == null || displayErrorText.isEmpty))
                      Text(
                        widget.supportText!,
                        style: TextStyle(
                          fontSize: bSSize,
                          fontWeight: bSWeight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundWeakestColor,
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
        backgroundColor: _selected
            ? Theme.of(context).extension<AppTheme>()?.backgroundStrongColor
            : null,
        foregroundColor: _selected
            ? Theme.of(context).extension<AppTheme>()?.foregroundStrongestColor
            : Theme.of(context).extension<AppTheme>()?.foregroundWeakColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(_value),
    );
  }
}
