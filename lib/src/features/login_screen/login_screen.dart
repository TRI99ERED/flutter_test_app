import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    if (!mounted) return;

    // Check if fields have content and would pass validation
    final email = _emailController.text;
    final password = _passwordController.text;

    final emailValidator = getValidatorForKeyboardType(
      TextInputType.emailAddress,
    );
    final passwordValidator = getValidatorForKeyboardType(
      TextInputType.visiblePassword,
    );

    final isValid =
        email.isNotEmpty &&
        password.isNotEmpty &&
        (emailValidator == null || emailValidator(email) == null) &&
        (passwordValidator == null || passwordValidator(password) == null);

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
              const PlaceholderImage(),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: spacing24,
                    vertical: spacing40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing24,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: h1Size,
                          fontWeight: h1Weight,
                          color: DarkColor.darkest.color,
                        ),
                      ),
                      AppTextField(
                        placeholder: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: getValidatorForKeyboardType(
                          TextInputType.emailAddress,
                        ),
                      ),
                      AppTextField(
                        placeholder: 'Password',
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: getValidatorForKeyboardType(
                          TextInputType.visiblePassword,
                        ),
                        obscureText: true,
                        showVisibilityIcon: true,
                      ),
                      AppButtonTertiary(
                        onPressed: () => context.go(forgotPasswordPath),
                        text: 'Forgot Password?',
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonPrimary(
                          onPressed: _isFormValid
                              ? () async {
                                  final email = _emailController.text;
                                  final password = _passwordController.text;

                                  await context.appController.login(
                                    email,
                                    password,
                                  );
                                }
                              : null,
                          text: 'Login',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Not a member?'),
                          AppButtonTertiary(
                            onPressed: () => context.go(registerPath),
                            text: 'Register now',
                          ),
                        ],
                      ),
                      AppDivider(),
                      Center(child: Text('Or continue with')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: spacing12,
                        children: [
                          IconButton(
                            onPressed: () =>
                                debugPrint('Google login is disabled'),
                            style: IconButton.styleFrom(
                              backgroundColor: ErrorColor.dark.color,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.google,
                              size: 12,
                              color: LightColor.lightest.color,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                debugPrint('Apple login is disabled'),
                            style: IconButton.styleFrom(
                              backgroundColor: DarkColor.darkest.color,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.apple,
                              size: 12,
                              color: LightColor.lightest.color,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                debugPrint('Facebook login is disabled'),
                            style: IconButton.styleFrom(
                              backgroundColor: HighlightColor.darkest.color,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.facebook,
                              size: 12,
                              color: LightColor.lightest.color,
                            ),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
