import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    this.obscurePassword = true,
    this.forgotPasswordCallback,
    this.loginCallback,
    this.registerCallback,
    this.passwordSuffixIconCallback,
  });

  final bool obscurePassword;
  final VoidCallback? forgotPasswordCallback;
  final VoidCallback? loginCallback;
  final VoidCallback? registerCallback;
  final VoidCallback? passwordSuffixIconCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome!'),
        const TextField(
          decoration: InputDecoration(labelText: 'Email Address'),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              onPressed: passwordSuffixIconCallback,
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          obscureText: obscurePassword,
        ),
        TextButton(
          onPressed: forgotPasswordCallback,
          child: const Text('Forgot Password?'),
        ),
        Center(
          child: ElevatedButton(onPressed: loginCallback, child: Text('Login')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Not a member?'),
            TextButton(
              onPressed: registerCallback,
              child: const Text('Register now'),
            ),
          ],
        ),
        Divider(),
        Center(child: Text('Or continue with')),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.g_mobiledata)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.apple)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.facebook)),
          ],
        ),
      ],
    );
  }
}
