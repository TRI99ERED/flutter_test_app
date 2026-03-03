import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyTextArea extends StatefulWidget {
  final String title;
  final bool enabled;
  final int maxLines;
  final String? placeholder;
  final String? text;
  final String? errorText;
  final String? supportText;
  final String? unit;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? controller;

  MyTextArea({
    super.key,
    required this.title,
    this.enabled = true,
    this.maxLines = 2,
    this.placeholder,
    this.text,
    this.errorText,
    this.supportText,
    this.unit,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.controller,
  }) {
    if (unit != null) {
      assert(
        unit!.length == 1 && unit!.trim().isNotEmpty,
        'unit must be a single non-whitespace character if provided',
      );
    }
  }

  @override
  State<MyTextArea> createState() => _MyTextAreaState();
}

class _MyTextAreaState extends State<MyTextArea> {
  String? _validatorErrorText;

  String? _getDisplayErrorText() {
    final customError = widget.errorText;
    if (customError != null && customError.isNotEmpty) {
      return customError;
    }
    return _validatorErrorText;
  }

  void _syncValidatorError(String? value) {
    if (widget.validator == null) {
      return;
    }
    final nextError = widget.validator!(value);
    if (nextError != _validatorErrorText && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _validatorErrorText = nextError;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayErrorText = _getDisplayErrorText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: bMSize,
            fontWeight: bMWeight,
            color: widget.enabled
                ? DarkColor.darkest.color
                : DarkColor.lightest.color,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.text,
          onChanged: (value) {
            final nextError = widget.validator?.call(value);
            if (nextError != _validatorErrorText) {
              setState(() {
                _validatorErrorText = nextError;
              });
            }
            widget.onChanged?.call(value);
          },
          validator: (value) {
            final result = widget.validator?.call(value);
            _syncValidatorError(value);
            return result;
          },
          autovalidateMode: widget.autovalidateMode,
          maxLines: widget.maxLines,
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
              borderSide: BorderSide(color: LightColor.darkest.color, width: 2),
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
              borderSide: BorderSide(color: ErrorColor.medium.color, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: ErrorColor.dark.color, width: 2),
            ),
            fillColor: LightColor.darkest.color,
            filled: !widget.enabled,
            prefixText: widget.unit != null ? '${widget.unit} ' : null,
          ),
        ),
        if (displayErrorText != null && displayErrorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              displayErrorText,
              style: TextStyle(
                fontSize: bSSize,
                fontWeight: bSWeight,
                color: ErrorColor.dark.color,
              ),
            ),
          ),
        if (widget.supportText != null &&
            (displayErrorText == null || displayErrorText.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.supportText!,
              style: TextStyle(
                fontSize: bSSize,
                fontWeight: bSWeight,
                color: DarkColor.lightest.color,
              ),
            ),
          ),
      ],
    );
  }
}
