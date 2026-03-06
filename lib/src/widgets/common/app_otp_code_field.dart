import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppOtpCodeField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final double boxWidth;
  final double boxHeight;
  final double boxSpacing;
  final bool autoUnfocusOnComplete;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const AppOtpCodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.length = 4,
    this.boxWidth = 60,
    this.boxHeight = 56,
    this.boxSpacing = 8,
    this.autoUnfocusOnComplete = true,
    this.onChanged,
    this.onCompleted,
  }) : assert(length > 0, 'length must be greater than 0');

  @override
  State<AppOtpCodeField> createState() => _AppOtpCodeFieldState();
}

class _AppOtpCodeFieldState extends State<AppOtpCodeField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppOtpCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onTextChanged() {
    if (!mounted) {
      return;
    }

    final rawText = widget.controller.text;
    final normalized = _normalizeCodeInput(rawText);

    if (normalized != rawText) {
      widget.controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
      return;
    }

    widget.onChanged?.call(normalized);

    if (normalized.length == widget.length) {
      widget.onCompleted?.call(normalized);
      if (widget.autoUnfocusOnComplete) {
        FocusScope.of(context).unfocus();
      }
    }

    setState(() {});
  }

  String _normalizeCodeInput(String rawText) {
    if (rawText.isEmpty) {
      return '';
    }

    if (!RegExp(r'[^0-9]').hasMatch(rawText)) {
      return rawText.length > widget.length
          ? rawText.substring(0, widget.length)
          : rawText;
    }

    final extracted = _extractCodeFromText(rawText);
    if (extracted != null) {
      return extracted;
    }

    final digitsOnly = rawText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length <= widget.length) {
      return digitsOnly;
    }

    return digitsOnly.substring(0, widget.length);
  }

  String? _extractCodeFromText(String text) {
    if (text.trim().isEmpty) {
      return null;
    }

    final codeLengthPattern = '\\d{${widget.length}}';
    final contextualMatch = RegExp(
      '(verification|confirmation)\\s*code[^0-9]{0,40}($codeLengthPattern)',
      caseSensitive: false,
    ).firstMatch(text);
    if (contextualMatch != null) {
      return contextualMatch.group(2);
    }

    final genericCodeMatch = RegExp(
      '\\bcode\\b[^0-9]{0,30}($codeLengthPattern)',
      caseSensitive: false,
    ).firstMatch(text);
    if (genericCodeMatch != null) {
      return genericCodeMatch.group(1);
    }

    final groups = RegExp(
      '\\b$codeLengthPattern\\b',
    ).allMatches(text).map((m) => m.group(0)!).toList();
    if (groups.isNotEmpty) {
      return groups.first;
    }

    return null;
  }

  Future<void> _pasteCodeFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text ?? '';
    final parsedCode = _normalizeCodeInput(text);
    if (parsedCode.isEmpty) {
      return;
    }

    widget.controller.value = TextEditingValue(
      text: parsedCode,
      selection: TextSelection.collapsed(offset: parsedCode.length),
    );
  }

  Widget _buildCodeDigitBox(int index) {
    final code = widget.controller.text;
    final digit = index < code.length ? code[index] : '';
    final focusedIndex = code.length.clamp(0, widget.length - 1).toInt();
    final isActive =
        widget.focusNode.hasFocus &&
        code.length < widget.length &&
        index == focusedIndex;

    return Container(
      width: widget.boxWidth,
      height: widget.boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LightColor.lightest.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? HighlightColor.darkest.color
              : LightColor.darkest.color,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 120),
        child: digit.isNotEmpty
            ? Text(
                digit,
                key: ValueKey<String>('digit-$index-$digit'),
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: DarkColor.darkest.color,
                ),
              )
            : isActive
            ? _BlinkingCaret(key: ValueKey<String>('caret-$index'))
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputWidth =
        (widget.boxWidth * widget.length) +
        (widget.boxSpacing * (widget.length - 1));

    return SizedBox(
      width: inputWidth,
      height: widget.boxHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            onTap: () {
              final length = widget.controller.text.length;
              widget.controller.selection = TextSelection.collapsed(
                offset: length,
              );
            },
            showCursor: false,
            enableInteractiveSelection: true,
            contextMenuBuilder: (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: [
                  ContextMenuButtonItem(
                    label: 'Paste code',
                    onPressed: () async {
                      ContextMenuController.removeAny();
                      await _pasteCodeFromClipboard();
                    },
                  ),
                ],
              );
            },
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
          ),
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: widget.boxSpacing,
              children: List.generate(widget.length, _buildCodeDigitBox),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({super.key});

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret> {
  Timer? _blinkTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVisible = !_isVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isVisible ? 1 : 0,
      child: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: HighlightColor.darkest.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }
}
