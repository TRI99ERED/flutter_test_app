import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
            physics: NeverScrollableScrollPhysics(),
            children: [
              const PlaceholderImage(),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome!'),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => {},
                          icon: Icon(AppIcons.eyeInvisible),
                        ),
                      ),
                      obscureText: true,
                    ),
                    TextButton(
                      onPressed: () => context.go(forgotPasswordPath),
                      child: const Text('Forgot Password?'),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = emailController.text;
                          final password = passwordController.text;

                          await context.appController.login(email, password);
                        },
                        child: Text('Login'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Not a member?'),
                        TextButton(
                          onPressed: () => context.go(registerPath),
                          child: const Text('Register now'),
                        ),
                      ],
                    ),
                    Divider(),
                    Center(child: Text('Or continue with')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () =>
                              debugPrint('Google login is disabled'),
                          icon: const Icon(AppIcons.google),
                        ),
                        IconButton(
                          onPressed: () =>
                              debugPrint('Apple login is disabled'),
                          icon: const Icon(AppIcons.apple),
                        ),
                        IconButton(
                          onPressed: () =>
                              debugPrint('Facebook login is disabled'),
                          icon: const Icon(AppIcons.facebook),
                        ),
                      ],
                    ),
                  ],
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
