import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

// Email validator
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(value)) return 'Invalid email format';
  return null;
}

// Number validator
String? _validateNumber(String? value) {
  if (value == null || value.isEmpty) return 'Number is required';
  if (int.tryParse(value) == null) return 'Must be a valid number';
  return null;
}

// Decimal validator
String? _validateDecimal(String? value) {
  if (value == null || value.isEmpty) return 'Number is required';
  if (double.tryParse(value) == null) return 'Must be a valid decimal';
  return null;
}

// Phone validator
String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Phone is required';
  if (value.length < 10) return 'Phone must be at least 10 digits';
  if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
    return 'Invalid phone format';
  }
  return null;
}

// URL validator
String? _validateUrl(String? value) {
  if (value == null || value.isEmpty) return 'URL is required';
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return 'URL must start with http:// or https://';
  }
  return null;
}

// Text validator
String? _validateText(String? value) {
  if (value == null || value.isEmpty) return 'This field is required';
  return null;
}

// Name validator
String? _validateName(String? value) {
  if (value == null || value.isEmpty) return 'Name is required';
  if (value.length < 2) return 'Name must be at least 2 characters';
  if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(value)) {
    return 'Name can only contain letters, spaces, hyphens, and periods';
  }
  return null;
}

// Street address validator
String? _validateStreetAddress(String? value) {
  if (value == null || value.isEmpty) return 'Address is required';
  if (value.length < 5) return 'Address must be at least 5 characters';
  return null;
}

// Datetime validator
String? _validateDatetime(String? value) {
  if (value == null || value.isEmpty) return 'Date/time is required';
  return null;
}

// Visible password validator
String? _validateVisiblePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  return null;
}

String? Function(String?)? getValidatorForKeyboardType(TextInputType? type) {
  if (type == TextInputType.emailAddress) {
    return _validateEmail;
  } else if (type == TextInputType.number) {
    return _validateNumber;
  } else if (type == const TextInputType.numberWithOptions(decimal: true)) {
    return _validateDecimal;
  } else if (type == TextInputType.phone) {
    return _validatePhone;
  } else if (type == TextInputType.url) {
    return _validateUrl;
  } else if (type == TextInputType.text) {
    return _validateText;
  } else if (type == TextInputType.name) {
    return _validateName;
  } else if (type == TextInputType.streetAddress) {
    return _validateStreetAddress;
  } else if (type == TextInputType.datetime) {
    return _validateDatetime;
  } else if (type == TextInputType.visiblePassword) {
    return _validateVisiblePassword;
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
  late bool _obscureText;
  String? _validatorErrorText;
  late TextEditingController _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

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
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _internalController = TextEditingController();

    if (widget.text != null) {
      _effectiveController.text = widget.text!;
      _validatorErrorText = widget.validator?.call(widget.text);
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
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayErrorText = _getDisplayErrorText();
    final hasError = displayErrorText != null && displayErrorText.isNotEmpty;

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
                  ? DarkColor.darkest.color
                  : DarkColor.lightest.color,
            ),
          ),
        TextFormField(
          controller: _effectiveController,
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            final nextError = widget.validator?.call(value);
            if (nextError != _validatorErrorText) {
              setState(() {
                _validatorErrorText = nextError;
              });
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
          enabled: widget.enabled,
          obscureText: _obscureText,
          textAlign: widget.textAlign ?? TextAlign.start,
          maxLength: widget.maxLength,
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
            errorText: hasError && widget.showErrorText ? '' : null,
            errorStyle: const TextStyle(height: 0.01),
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
                    ? ErrorColor.medium.color
                    : LightColor.darkest.color,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: !widget.showErrorText && hasError
                    ? ErrorColor.medium.color
                    : LightColor.darkest.color,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: !widget.showErrorText && hasError
                    ? ErrorColor.dark.color
                    : HighlightColor.darkest.color,
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
            suffixIcon: widget.showVisibilityIcon
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText
                          ? AppIcons.eyeInvisible
                          : AppIcons.eyeVisible,
                      size: 16,
                      color: DarkColor.lightest.color,
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
    );
  }
}
