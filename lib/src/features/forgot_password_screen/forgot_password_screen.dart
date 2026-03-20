import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/features/themes/styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
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
          context.go(loginPath);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
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
                        context.l10n.resetPasswordLabel,
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
                      SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isFormValid,
                          builder: (context, isValid, _) {
                            return AppButtonPrimary(
                              onPressed: isValid
                                  ? () async {
                                      final email = _emailController.text;
                                      await context.appController
                                          .sendPasswordResetEmail(email);
                                    }
                                  : null,
                              text: context.l10n.sendPasswordResetEmailLabel,
                            );
                          },
                        ),
                      ),
                      AppDivider(),
                      Center(
                        child: AppButtonTertiary(
                          onPressed: () => context.go(loginPath),
                          text: context.l10n.backToLoginLabel,
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
    _emailController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }
}
