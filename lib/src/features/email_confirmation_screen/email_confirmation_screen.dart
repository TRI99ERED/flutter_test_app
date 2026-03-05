import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key});

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _firstDigitController = TextEditingController();
  final _secondDigitController = TextEditingController();
  final _thirdDigitController = TextEditingController();
  final _fourthDigitController = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _firstDigitController.addListener(_validateForm);
    _secondDigitController.addListener(_validateForm);
    _thirdDigitController.addListener(_validateForm);
    _fourthDigitController.addListener(_validateForm);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.appController.sendEmailVerification();
    });
  }

  void _validateForm() {
    if (!mounted) return;

    // Check if fields have content and would pass validation
    final firstDigit = _firstDigitController.text;
    final secondDigit = _secondDigitController.text;
    final thirdDigit = _thirdDigitController.text;
    final fourthDigit = _fourthDigitController.text;

    final digitValidator = getValidatorForKeyboardType(TextInputType.number);

    final isValid =
        firstDigit.isNotEmpty &&
        secondDigit.isNotEmpty &&
        thirdDigit.isNotEmpty &&
        fourthDigit.isNotEmpty &&
        (digitValidator == null || digitValidator(firstDigit) == null) &&
        (digitValidator == null || digitValidator(secondDigit) == null) &&
        (digitValidator == null || digitValidator(thirdDigit) == null) &&
        (digitValidator == null || digitValidator(fourthDigit) == null);

    if (isValid != _isFormValid.value) {
      _isFormValid.value = isValid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ControllerListener(
        controller: context.appController,
        listenWhen: (previous, current) {
          return previous.isProcessing &&
              previous.message == 'Verifying email code...' &&
              !current.isProcessing &&
              !current.isFailed &&
              current.message == 'Email verified successfully';
        },
        listener: (context, previous, current) {
          // Navigate to home after successful verification
          context.go(homePath);
        },
        child: ControllerListener(
          controller: context.appController,
          listenWhen: (previous, current) {
            return !previous.isFailed && current.isFailed;
          },
          listener: (context, previous, current) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${current.message}')),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: spacing40,
              children: [
                Column(
                  spacing: spacing8,
                  children: [
                    Text(
                      'Enter confirmation code',
                      style: TextStyle(
                        fontSize: h3Size,
                        fontWeight: h3Weight,
                        color: DarkColor.darkest.color,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final user = context.appState.user;
                        final email = user is AuthorizedUser
                            ? user.email
                            : 'your email';
                        return Text(
                          'A 4-digit code was sent to\n$email',
                          style: TextStyle(
                            fontSize: bSSize,
                            fontWeight: bSWeight,
                            color: DarkColor.light.color,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Form(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: spacing8,
                    children: [
                      SizedBox(
                        width: 60,
                        child: AppTextField(
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _firstDigitController,
                          keyboardType: TextInputType.number,
                          showCounter: false,
                          showErrorText: false,
                          validator: getValidatorForKeyboardType(
                            TextInputType.number,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: AppTextField(
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _secondDigitController,
                          keyboardType: TextInputType.number,
                          showCounter: false,
                          showErrorText: false,
                          validator: getValidatorForKeyboardType(
                            TextInputType.number,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: AppTextField(
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _thirdDigitController,
                          keyboardType: TextInputType.number,
                          showCounter: false,
                          showErrorText: false,
                          validator: getValidatorForKeyboardType(
                            TextInputType.number,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: AppTextField(
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fourthDigitController,
                          keyboardType: TextInputType.number,
                          showCounter: false,
                          showErrorText: false,
                          validator: getValidatorForKeyboardType(
                            TextInputType.number,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  spacing: spacing12,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppButtonTertiary(
                        text: 'Resend code',
                        onPressed: () {
                          context.appController.resendEmailVerification();
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isFormValid,
                        builder: (context, isFormValid, child) {
                          return AppButtonPrimary(
                            text: 'Continue',
                            onPressed: isFormValid
                                ? () {
                                    final code =
                                        '${_firstDigitController.text}${_secondDigitController.text}${_thirdDigitController.text}${_fourthDigitController.text}';
                                    context.appController.verifyEmailCode(code);
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstDigitController.dispose();
    _secondDigitController.dispose();
    _thirdDigitController.dispose();
    _fourthDigitController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }
}
