import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AppSearchBar extends StatefulWidget {
  final String? text;
  final String placeholder;
  final List<String>? recentSearches;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onDelete;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.text,
    required this.placeholder,
    this.recentSearches,
    this.onChanged,
    this.onSubmitted,
    this.onDelete,
    this.controller,
  }) : assert(
         controller == null || text == null,
         'controller and text cannot both be provided',
       );

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  late TextEditingController _internalController;

  late final KeyboardVisibilityController _keyboardVisibilityController;
  late final StreamSubscription<bool> _keyboardSubscription;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    if (widget.text != null) {
      _effectiveController.text = widget.text!;
    }

    _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription = _keyboardVisibilityController.onChange.listen((
      bool visible,
    ) {
      if (!visible) {
        _hideOverlay();
      }
    });
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
    _hideOverlay();
    _keyboardSubscription.cancel();
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    if (widget.recentSearches == null) {
      return;
    }

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final size = renderBox.size;

    final overlayOffset = Offset(0, size.height + 4);

    final barTopLeft = renderBox.localToGlobal(Offset.zero);
    final barBottom = barTopLeft.dy + size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barTopLeft.dy,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _hideOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
          Positioned(
            left: 0,
            top: barTopLeft.dy,
            width: barTopLeft.dx,
            height: size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _hideOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
          Positioned(
            left: barTopLeft.dx + size.width,
            top: barTopLeft.dy,
            right: 0,
            height: size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _hideOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: barBottom + 4 + size.height,
            bottom: 0,
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
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    borderRadius: BorderRadius.zero,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height,
                    maxWidth: size.width,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(spacing16),
                        child: Text(
                          context.l10n.recentSearchesLabel,
                          style: TextStyle(
                            fontSize: cMSize,
                            fontWeight: cMWeight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundWeakColor,
                          ),
                        ),
                      ),
                      widget.recentSearches == null ||
                              widget.recentSearches!.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: spacing8,
                                  horizontal: spacing16,
                                ),
                                child: Text(
                                  context.l10n.noRecentSearchesFoundLabel,
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
                          : ListView(
                              padding: EdgeInsets.all(spacing8),
                              shrinkWrap: true,
                              children: widget.recentSearches!.map((entry) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: spacing2,
                                  ),
                                  child: _AppRecentSearch(
                                    value: entry,
                                    onPressed: () {
                                      _hideOverlay();
                                      _focusNode.unfocus();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted) {
                                              _effectiveController.text = entry;
                                              widget.onChanged?.call(entry);
                                            }
                                          });
                                    },
                                    onDelete: () {
                                      widget.onDelete?.call(entry);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        key: _textFieldKey,
        focusNode: _focusNode,
        controller: _effectiveController,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        cursorColor: Theme.of(
          context,
        ).extension<AppTheme>()?.highlightDarkestColor,
        style: TextStyle(
          color: Theme.of(
            context,
          ).extension<AppTheme>()?.foregroundStrongestColor,
          fontSize: bMSize,
          fontWeight: bMWeight,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.webSearch,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).extension<AppTheme>()?.foregroundWeakestColor,
            fontSize: bMSize,
            fontWeight: bMWeight,
          ),
          prefixIcon: Icon(
            AppIcons.search,
            color: Theme.of(
              context,
            ).extension<AppTheme>()?.foregroundStrongColor,
            size: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).extension<AppTheme>()?.backgroundStrongColor,
        ),
        onTap: () {
          _showOverlay();
        },
        onEditingComplete: () {
          widget.onSubmitted?.call(_effectiveController.text);
          _hideOverlay();
          _focusNode.unfocus();
        },
      ),
    );
  }
}

class _AppRecentSearch extends StatelessWidget {
  final String _value;
  final VoidCallback? _onPressed;
  final VoidCallback? _onDelete;

  const _AppRecentSearch({
    required String value,
    void Function()? onPressed,
    void Function()? onDelete,
  }) : _value = value,
       _onPressed = onPressed,
       _onDelete = onDelete;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        foregroundColor: Theme.of(
          context,
        ).extension<AppTheme>()?.foregroundStrongestColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(spacing8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_value),
          Center(
            child: SizedBox(
              width: spacing24,
              height: spacing24,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _onDelete,
                icon: Icon(
                  AppIcons.delete,
                  size: 12,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundWeakestColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
