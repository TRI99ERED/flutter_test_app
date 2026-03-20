import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/themes/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      _isFormValid.value = isValid;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongColor,
              content: Text(
                '${context.l10n.errorLabel}: ${current.message}',
                style: TextStyle(
                  fontSize: cMSize,
                  fontWeight: cMWeight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
            ),
          );
        } else if (current.isAuthorized && !previous.isAuthorized) {
          context.go(homePath);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
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
                        context.l10n.welcomeLabel,
                        style: TextStyle(
                          fontSize: h1Size,
                          fontWeight: h1Weight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundStrongestColor,
                        ),
                      ),
                      AppTextField(
                        placeholder: context.l10n.emailAddressLabel,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: getValidatorForKeyboardType(
                          context,
                          TextInputType.emailAddress,
                        ),
                        onChanged: (_) => _validateForm(),
                      ),
                      AppTextField(
                        placeholder: context.l10n.passwordLabel,
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: getValidatorForKeyboardType(
                          context,
                          TextInputType.visiblePassword,
                        ),
                        obscureText: true,
                        showVisibilityIcon: true,
                        onChanged: (_) => _validateForm(),
                      ),
                      AppButtonTertiary(
                        onPressed: () => context.go(forgotPasswordPath),
                        text: context.l10n.forgotPasswordLabel,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isFormValid,
                          builder: (context, isValid, _) {
                            return AppButtonPrimary(
                              onPressed: isValid
                                  ? () async {
                                      final email = _emailController.text;
                                      final password = _passwordController.text;
                                      await context.appController.login(
                                        email,
                                        password,
                                      );
                                    }
                                  : null,
                              text: context.l10n.loginLabel,
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.notAMemberLabel,
                            style: TextStyle(
                              fontSize: bSSize,
                              fontWeight: bSWeight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongestColor,
                            ),
                          ),
                          AppButtonTertiary(
                            onPressed: () => context.go(registerPath),
                            text: context.l10n.registerNowLabel,
                          ),
                        ],
                      ),
                      AppDivider(),
                      Center(
                        child: Text(
                          context.l10n.orContinueWithLabel,
                          style: TextStyle(
                            fontSize: bSSize,
                            fontWeight: bSWeight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: spacing12,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (kIsWeb) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.backgroundStrongColor,
                                    content: Text(
                                      context
                                          .l10n
                                          .googleSignInIsNotAvailableOnWebLabel,
                                      style: TextStyle(
                                        fontSize: cMSize,
                                        fontWeight: cMWeight,
                                        color: Theme.of(context)
                                            .extension<AppTheme>()
                                            ?.foregroundStrongestColor,
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              await context.appController.signInWithGoogle();
                              if (!context.mounted) return;
                              context.go(interestsPath);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).extension<AppTheme>()?.errorDarkColor,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.google,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundStrongColor,
                                  content: Text(
                                    context.l10n.appleSignInNotImplementedLabel,
                                    style: TextStyle(
                                      fontSize: cMSize,
                                      fontWeight: cMWeight,
                                      color: Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.foregroundStrongestColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongestColor,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.apple,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(context)
                                      .extension<AppTheme>()
                                      ?.backgroundStrongColor,
                                  content: Text(
                                    context
                                        .l10n
                                        .facebookSignInNotImplementedLabel,
                                    style: TextStyle(
                                      fontSize: cMSize,
                                      fontWeight: cMWeight,
                                      color: Theme.of(context)
                                          .extension<AppTheme>()
                                          ?.foregroundStrongestColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).extension<AppTheme>()?.highlightDarkestColor,
                              fixedSize: Size(40, 40),
                            ),
                            icon: Icon(
                              AppIcons.facebook,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
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
    _isFormValid.dispose();
    super.dispose();
  }
}
