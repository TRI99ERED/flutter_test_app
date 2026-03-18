import 'package:flutter/material.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppTextArea extends StatefulWidget {
  final String? title;
  final bool enabled;
  final int maxLines;
  final String? placeholder;
  final String? text;
  final String? errorText;
  final String? supportText;
  final String? unit;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? controller;

  AppTextArea({
    super.key,
    this.title,
    this.enabled = true,
    this.maxLines = 2,
    this.placeholder,
    this.text,
    this.errorText,
    this.supportText,
    this.unit,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.controller,
  }) : assert(
         controller == null || text == null,
         'controller and text cannot both be provided',
       ) {
    if (unit != null) {
      assert(
        unit!.length == 1 && unit!.trim().isNotEmpty,
        'unit must be a single non-whitespace character if provided',
      );
    }
  }

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  late final ValueNotifier<String?> _validatorErrorText;
  late TextEditingController _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  String? _getDisplayErrorText(String? validatorErrorText) {
    final customError = widget.errorText;
    if (customError != null && customError.isNotEmpty) {
      return customError;
    }
    return validatorErrorText;
  }

  void _syncValidatorError(String? value) {
    if (widget.validator == null) {
      return;
    }
    final nextError = widget.validator!(value);
    if (nextError != _validatorErrorText.value && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _validatorErrorText.value = nextError;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _validatorErrorText = ValueNotifier<String?>(null);
    _internalController = TextEditingController();

    if (widget.text != null) {
      _effectiveController.text = widget.text!;
      _validatorErrorText.value = widget.validator?.call(widget.text);
    }
  }

  @override
  void didUpdateWidget(AppTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && widget.text != oldWidget.text) {
      _internalController.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    _validatorErrorText.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _validatorErrorText,
      builder: (context, validatorErrorText, _) {
        final displayErrorText = _getDisplayErrorText(validatorErrorText);

        return Column(
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
                      ? Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongestColor
                      : Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundWeakestColor,
                ),
              ),
            TextFormField(
              controller: _effectiveController,
              onChanged: (value) {
                final nextError = widget.validator?.call(value);
                if (nextError != _validatorErrorText.value) {
                  _validatorErrorText.value = nextError;
                }
                widget.onChanged?.call(value);
              },
              onFieldSubmitted: widget.onSubmitted,
              validator: (value) {
                final result = widget.validator?.call(value);
                _syncValidatorError(value);
                return result;
              },
              autovalidateMode: widget.autovalidateMode,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              cursorColor: Theme.of(
                context,
              ).extension<AppTheme>()?.highlightDarkestColor,
              cursorErrorColor: Theme.of(
                context,
              ).extension<AppTheme>()?.errorDarkColor,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: widget.enabled
                    ? Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundStrongestColor
                    : Theme.of(
                        context,
                      ).extension<AppTheme>()?.foregroundWeakestColor,
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
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).extension<AppTheme>()?.backgroundWeakestColor ??
                        Color(0xFFC5C6CC),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).extension<AppTheme>()?.highlightDarkestColor ??
                        const Color(0xFF006FFD),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).extension<AppTheme>()?.errorMediumColor ??
                        const Color(0xFFFF616D),
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).extension<AppTheme>()?.errorDarkColor ??
                        const Color(0xFFED3241),
                    width: 2,
                  ),
                ),
                fillColor: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundWeakestColor,
                filled: !widget.enabled,
                prefixText: widget.unit != null ? '${widget.unit} ' : null,
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
        );
      },
    );
  }
}
