import 'package:flutter/material.dart';
import 'package:test_app/src/app_scope.dart';
import 'package:test_app/src/components/placeholder_image.dart';
import 'package:test_app/src/controller_builder.dart';
import 'package:test_app/src/controller_listener.dart';
import 'package:test_app/src/login_form.dart';

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
      },
      child: Scaffold(
        body: Column(
          children: [
            const PlaceholderImage(),
            ControllerBuilder(
              controller: context.appController,
              buildWhen: (previous, current) =>
                  previous.obscurePassword != current.obscurePassword,
              builder: (context, state) {
                return LoginForm(
                  obscurePassword: state.obscurePassword,
                  forgotPasswordCallback: context.appController.forgotPassword,
                  loginCallback: context.appController.login,
                  registerCallback: context.appController.register,
                  passwordSuffixIconCallback:
                      context.appController.toggleObscurePassword,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
