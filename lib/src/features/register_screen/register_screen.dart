import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/features/themes/styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _isFormValid = ValueNotifier(false);
  final _termsAccepted = ValueNotifier<bool?>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _termsAccepted.addListener(_validateForm);
  }

  void _validateForm() {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      _isFormValid.value = isValid && (_termsAccepted.value == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        return previous.isProcessing &&
            !current.isProcessing &&
            !current.isFailed &&
            current.isAuthorized;
      },
      listener: (context, previous, current) {
        context.go(emailConfirmationPath);
      },
      child: ControllerListener(
        controller: context.appController,
        listenWhen: (previous, current) {
          return !previous.isFailed && current.isFailed;
        },
        listener: (context, previous, current) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
        },
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.all(spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing24,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: spacing8,
                          children: [
                            Text(
                              'Sign up!',
                              style: TextStyle(
                                fontSize: h3Size,
                                fontWeight: h3Weight,
                                color: Theme.of(context)
                                    .extension<AppTheme>()
                                    ?.foregroundStrongestColor,
                              ),
                            ),
                            Text(
                              'Create an account to get started',
                              style: TextStyle(
                                fontSize: bSSize,
                                fontWeight: bSWeight,
                                color: Theme.of(
                                  context,
                                ).extension<AppTheme>()?.foregroundWeakColor,
                              ),
                            ),
                          ],
                        ),
                        AppTextField(
                          title: 'Name',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: getValidatorForKeyboardType(
                            TextInputType.name,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        AppTextField(
                          title: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: getValidatorForKeyboardType(
                            TextInputType.emailAddress,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        AppTextField(
                          title: 'Password',
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: getValidatorForKeyboardType(
                            TextInputType.visiblePassword,
                          ),
                          obscureText: true,
                          showVisibilityIcon: true,
                          onChanged: (_) => _validateForm(),
                        ),
                        AppTextField(
                          title: 'Confirm Password',
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
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
                          },
                          obscureText: true,
                          showVisibilityIcon: true,
                          onChanged: (_) => _validateForm(),
                        ),
                        ValueListenableBuilder<bool?>(
                          valueListenable: _termsAccepted,
                          builder: (context, termsAccepted, child) {
                            return Row(
                              children: [
                                AppCheckbox(
                                  value: termsAccepted ?? false,
                                  onChanged: (value) {
                                    _termsAccepted.value = value;
                                  },
                                ),
                                Expanded(
                                  child: const Text(
                                    'I\'ve read and agree with the Terms and Conditions and the Privacy Policy.',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isFormValid,
                            builder: (context, isValid, _) {
                              return AppButtonPrimary(
                                text: 'Register',
                                onPressed: isValid
                                    ? () async {
                                        final name = _nameController.text;
                                        final email = _emailController.text;
                                        final password =
                                            _passwordController.text;
                                        await context.appController.register(
                                          email,
                                          password,
                                          name,
                                        );
                                        if (!context.mounted) return;
                                        context.go(emailConfirmationPath);
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                        AppDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: spacing8,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: bMSize,
                                fontWeight: bMWeight,
                                color: Theme.of(
                                  context,
                                ).extension<AppTheme>()?.foregroundWeakColor,
                              ),
                            ),
                            AppButtonTertiary(
                              onPressed: () {
                                context.go(loginPath);
                              },
                              text: 'Log in',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsAccepted.dispose();
    _isFormValid.dispose();
    super.dispose();
  }
}
