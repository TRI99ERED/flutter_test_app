import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        } else if (!current.isAuthorized && previous.isAuthorized) {
          context.go(loginPath);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        child: Scaffold(
          body: ListView(
            children: [
              ElevatedButton(
                onPressed: () => context.appController.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
