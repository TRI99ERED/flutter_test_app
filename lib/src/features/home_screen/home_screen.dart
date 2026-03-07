import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/home_screen/widgets/chats.dart';
import 'package:test_app/src/features/home_screen/widgets/friends.dart';
import 'package:test_app/src/features/home_screen/widgets/settings.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _selectedTabIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    // Guard: Only allow authorized users to access HomeScreen
    if (!context.appState.isAuthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(loginPath);
        }
      });
      return const Scaffold(
        body: Center(child: SizedBox(width: 32, child: AppLoader())),
      );
    }

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
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _selectedTabIndex,
          builder: (context, value, child) {
            return switch (_selectedTabIndex.value) {
              0 => Chats(selectedTabIndex: _selectedTabIndex),
              1 => Friends(selectedTabIndex: _selectedTabIndex),
              2 => Settings(selectedTabIndex: _selectedTabIndex),
              _ => SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
