import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.l10n.errorLabel}: ${current.message}'),
            ),
          );
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
                              context.l10n.signUpLabel,
                              style: TextStyle(
                                fontSize: h3Size,
                                fontWeight: h3Weight,
                                color: Theme.of(context)
                                    .extension<AppTheme>()
                                    ?.foregroundStrongestColor,
                              ),
                            ),
                            Text(
                              context.l10n.createAnAccountLabel,
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
                          title: context.l10n.nameLabel,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: getValidatorForKeyboardType(
                            context,
                            TextInputType.name,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        AppTextField(
                          title: context.l10n.emailAddressLabel,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: getValidatorForKeyboardType(
                            context,
                            TextInputType.emailAddress,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        AppTextField(
                          title: context.l10n.passwordLabel,
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
                        AppTextField(
                          title: context.l10n.confirmPasswordLabel,
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context
                                  .l10n
                                  .pleaseConfirmYourPasswordMessage;
                            }
                            if (value != _passwordController.text) {
                              return context.l10n.passwordsDoNotMatchMessage;
                            }
                            if (value.length < 8) {
                              return context
                                  .l10n
                                  .passwordMustBeAtLeast8CharactersMessage;
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return context
                                  .l10n
                                  .passwordMustContainAtLeastOneUppercaseLetterMessage;
                            }
                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return context
                                  .l10n
                                  .passwordMustContainAtLeastOneLowercaseLetterMessage;
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return context
                                  .l10n
                                  .passwordMustContainAtLeastOneNumberMessage;
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
                                  child: Text(
                                    context
                                        .l10n
                                        .iveReadAndAgreeWithTermsAndConditionsLabel,
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
                                text: context.l10n.registerLabel,
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
                              context.l10n.alreadyHaveAnAccountLabel,
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
                              text: context.l10n.loginLabel,
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
