import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

String? _validateEmail(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.emailIsRequiredMessage;
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(value)) {
    return context.l10n.invalidEmailFormatMessage;
  }
  return null;
}

String? _validateNumber(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.numberIsRequiredMessage;
  }
  if (int.tryParse(value) == null) {
    return context.l10n.mustBeAValidNumberMessage;
  }
  return null;
}

String? _validateDecimal(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.numberIsRequiredMessage;
  }
  if (double.tryParse(value) == null) {
    return context.l10n.mustBeAValidDecimalMessage;
  }
  return null;
}

String? _validatePhone(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.phoneNumberIsRequiredMessage;
  }
  if (value.length < 10) {
    return context.l10n.phoneNumberMustBeAtLeast10DigitsMessage;
  }
  if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
    return context.l10n.invalidPhoneNumberFormatMessage;
  }
  return null;
}

String? _validateUrl(BuildContext context, String? value) {
  if (value == null || value.isEmpty) return context.l10n.urlIsRequiredMessage;
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return context.l10n.urlMustStartWithHttpMessage;
  }
  return null;
}

String? _validateText(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.thisFieldIsRequiredMessage;
  }
  return null;
}

String? _validateName(BuildContext context, String? value) {
  if (value == null || value.isEmpty) return context.l10n.nameIsRequiredMessage;
  if (value.length < 2) return context.l10n.nameMustBeAtLeast2CharactersMessage;
  if (!RegExp(r'^[a-zA-Z0-9\s\-\.]+$').hasMatch(value)) {
    return context
        .l10n
        .nameMustContainLettersSpacesHyphensNumbersAndPeriodsMessage;
  }
  return null;
}

String? _validateStreetAddress(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.addressIsRequiredMessage;
  }
  if (value.length < 5) {
    return context.l10n.addressMustBeAtLeast5CharactersMessage;
  }
  return null;
}

String? _validateDatetime(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.dateTimeIsRequiredMessage;
  }
  return null;
}

String? _validateVisiblePassword(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return context.l10n.passwordIsRequiredMessage;
  }
  if (value.length < 8) {
    return context.l10n.passwordMustBeAtLeast8CharactersMessage;
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return context.l10n.passwordMustContainAtLeastOneUppercaseLetterMessage;
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return context.l10n.passwordMustContainAtLeastOneLowercaseLetterMessage;
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return context.l10n.passwordMustContainAtLeastOneNumberMessage;
  }
  return null;
}

String? Function(String?)? getValidatorForKeyboardType(
  BuildContext context,
  TextInputType? type,
) {
  if (type == TextInputType.emailAddress) {
    return (value) => _validateEmail(context, value);
  } else if (type == TextInputType.number) {
    return (value) => _validateNumber(context, value);
  } else if (type == const TextInputType.numberWithOptions(decimal: true)) {
    return (value) => _validateDecimal(context, value);
  } else if (type == TextInputType.phone) {
    return (value) => _validatePhone(context, value);
  } else if (type == TextInputType.url) {
    return (value) => _validateUrl(context, value);
  } else if (type == TextInputType.text) {
    return (value) => _validateText(context, value);
  } else if (type == TextInputType.name) {
    return (value) => _validateName(context, value);
  } else if (type == TextInputType.streetAddress) {
    return (value) => _validateStreetAddress(context, value);
  } else if (type == TextInputType.datetime) {
    return (value) => _validateDatetime(context, value);
  } else if (type == TextInputType.visiblePassword) {
    return (value) => _validateVisiblePassword(context, value);
  }
  return null;
}

class AppTextField extends StatefulWidget {
  final String? title;
  final bool enabled;
  final bool obscureText;
  final bool showVisibilityIcon;
  final String? placeholder;
  final String? text;
  final String? errorText;
  final String? supportText;
  final String? unit;
  final int? maxLength;
  final bool showCounter;
  final bool showErrorText;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? controller;

  AppTextField({
    super.key,
    this.title,
    this.enabled = true,
    this.obscureText = false,
    this.showVisibilityIcon = false,
    this.placeholder,
    this.text,
    this.errorText,
    this.supportText,
    this.unit,
    this.keyboardType,
    this.textAlign,
    this.maxLength,
    this.showCounter = true,
    this.showErrorText = true,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.controller,
  }) : assert(
         !(obscureText && !showVisibilityIcon),
         'obscureText can only be true when showVisibilityIcon is true',
       ),
       assert(
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final ValueNotifier<bool> _obscureText;
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
    _obscureText = ValueNotifier<bool>(widget.obscureText);
    _validatorErrorText = ValueNotifier<String?>(null);
    _internalController = TextEditingController();

    if (widget.text != null) {
      _effectiveController.text = widget.text!;
      _validatorErrorText.value = widget.validator?.call(widget.text);
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && widget.text != oldWidget.text) {
      _internalController.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    _obscureText.dispose();
    _validatorErrorText.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureText,
      builder: (context, obscureText, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _validatorErrorText,
          builder: (context, validatorErrorText, _) {
            final displayErrorText = _getDisplayErrorText(validatorErrorText);
            final hasError =
                displayErrorText != null && displayErrorText.isNotEmpty;

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
                  keyboardType: widget.keyboardType,
                  focusNode: widget.focusNode,
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
                    return widget.showErrorText ? result : null;
                  },
                  autovalidateMode: widget.autovalidateMode,
                  enabled: widget.enabled,
                  obscureText: obscureText,
                  textAlign: widget.textAlign ?? TextAlign.start,
                  maxLength: widget.maxLength,
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
                    errorText: hasError && widget.showErrorText ? '' : null,
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                    errorMaxLines: 1,
                    counterText: widget.showCounter ? null : '',
                    counterStyle: TextStyle(
                      fontSize: widget.showCounter ? bSSize : 0,
                      height: widget.showCounter ? 1 : 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: !widget.showErrorText && hasError
                            ? Theme.of(
                                    context,
                                  ).extension<AppTheme>()?.errorMediumColor ??
                                  const Color(0xFFFF616D)
                            : Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundWeakestColor ??
                                  const Color(0xFFC5C6CC),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: !widget.showErrorText && hasError
                            ? Theme.of(
                                    context,
                                  ).extension<AppTheme>()?.errorMediumColor ??
                                  const Color(0xFFFF616D)
                            : Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundWeakestColor ??
                                  const Color(0xFFC5C6CC),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: !widget.showErrorText && hasError
                            ? Theme.of(
                                    context,
                                  ).extension<AppTheme>()?.errorDarkColor ??
                                  const Color(0xFFED3241)
                            : Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.highlightDarkestColor ??
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
                    suffixIcon: widget.showVisibilityIcon
                        ? IconButton(
                            onPressed: () {
                              _obscureText.value = !_obscureText.value;
                            },
                            icon: Icon(
                              obscureText
                                  ? AppIcons.eyeInvisible
                                  : AppIcons.eyeVisible,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundWeakestColor,
                            ),
                          )
                        : null,
                  ),
                ),
                if (widget.showErrorText &&
                    displayErrorText != null &&
                    displayErrorText.isNotEmpty)
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
      },
    );
  }
}
