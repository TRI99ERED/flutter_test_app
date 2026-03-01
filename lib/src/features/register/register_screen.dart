import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign up!'),
                    const Text('Create an account to get started'),
                    const Text('Name'),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Test Test'),
                    ),
                    const Text('Email Address'),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'test@test.com',
                      ),
                    ),
                    const Text('Password'),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Create a password',
                        suffixIcon: IconButton(
                          onPressed: () => {},
                          icon: Icon(AppIcons.eyeInvisible),
                        ),
                      ),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        suffixIcon: IconButton(
                          onPressed: () => {},
                          icon: Icon(AppIcons.eyeInvisible),
                        ),
                      ),
                      obscureText: true,
                    ),
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) => {}),
                        const Text(
                          'I\'ve read and agree with the Terms and Conditions and the Privacy Policy',
                        ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text;
                          final email = emailController.text;
                          final password = passwordController.text;
                          final confirmPassword =
                              confirmPasswordController.text;

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
                        },
                        child: Text('Register'),
                      ),
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
