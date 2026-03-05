import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/styles.dart';

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
  bool _isFormValid = false;
  bool? _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    if (!mounted) return;

    // Check if fields have content and would pass validation
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final nameValidator = getValidatorForKeyboardType(TextInputType.name);
    final emailValidator = getValidatorForKeyboardType(
      TextInputType.emailAddress,
    );
    final passwordValidator = getValidatorForKeyboardType(
      TextInputType.visiblePassword,
    );

    final isValid =
        name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        (nameValidator == null || nameValidator(name) == null) &&
        (emailValidator == null || emailValidator(email) == null) &&
        (passwordValidator == null || passwordValidator(password) == null) &&
        (passwordValidator == null ||
            passwordValidator(confirmPassword) == null) &&
        (_termsAccepted == true);

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        if (!previous.isAuthorized && current.isAuthorized) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        if (current.isFailed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
        } else if (current.isAuthorized && !previous.isAuthorized) {
          context.go(homePath);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        child: Scaffold(
          body: ListView(
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
                              color: DarkColor.darkest.color,
                            ),
                          ),
                          Text(
                            'Create an account to get started',
                            style: TextStyle(
                              fontSize: bSSize,
                              fontWeight: bSWeight,
                              color: DarkColor.light.color,
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
                      ),
                      AppTextField(
                        title: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: getValidatorForKeyboardType(
                          TextInputType.emailAddress,
                        ),
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
                      ),
                      AppTextField(
                        title: 'Confirm Password',
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: getValidatorForKeyboardType(
                          TextInputType.visiblePassword,
                        ),
                        obscureText: true,
                        showVisibilityIcon: true,
                      ),
                      Row(
                        children: [
                          AppCheckbox(
                            value: _termsAccepted ?? false,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value;
                              });
                              _validateForm();
                            },
                          ),
                          Expanded(
                            child: const Text(
                              'I\'ve read and agree with the Terms and Conditions and the Privacy Policy.',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonPrimary(
                          onPressed: _isFormValid
                              ? () async {
                                  final name = _nameController.text;
                                  final email = _emailController.text;
                                  final password = _passwordController.text;
                                  final confirmPassword =
                                      _confirmPasswordController.text;

                                  if (password != confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Passwords do not match'),
                                      ),
                                    );
                                    return;
                                  }

                                  await context.appController.register(
                                    email,
                                    password,
                                    name,
                                  );
                                }
                              : null,
                          text: 'Register',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    super.dispose();
  }
}
