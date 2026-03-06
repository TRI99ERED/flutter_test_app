import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_otp_code_field.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key});

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.appController.sendEmailVerification();
      _codeFocusNode.requestFocus();
    });
  }

  void _onCodeChanged(String code) {
    final isValid = code.length == 4;
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
          child: SafeArea(
            child: SingleChildScrollView(
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
                  Column(
                    children: [
                      AppOtpCodeField(
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        length: 4,
                        boxSpacing: spacing8,
                        onChanged: _onCodeChanged,
                      ),
                    ],
                  ),
                  Column(
                    spacing: spacing12,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonTertiary(
                          text: 'Resend code',
                          onPressed: () {
                            _codeController.clear();
                            _codeFocusNode.requestFocus();
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
                                      final code = _codeController.text;
                                      context.appController.verifyEmailCode(
                                        code,
                                      );
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
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    _isFormValid.dispose();
    super.dispose();
  }
}
