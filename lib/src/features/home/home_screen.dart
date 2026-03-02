import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/my_badge.dart';
import 'package:test_app/src/widgets/common/my_banner.dart';
import 'package:test_app/src/widgets/common/my_button.dart';
import 'package:test_app/src/widgets/common/my_dialog.dart';
import 'package:test_app/src/widgets/common/my_toast.dart';
import 'package:test_app/src/widgets/common/my_tooltip.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';

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
              MyButtonPrimary(
                onPressed: () => context.appController.logout(),
                text: 'Logout',
              ),
              const SizedBox(height: 16),
              MyBanner(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed: () => {},
                buttonText: 'Button',
                image: const PlaceholderImage(),
              ),
              const SizedBox(height: 16),
              MyToastInformative(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => {},
              ),
              const SizedBox(height: 16),
              MyToastSuccess(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => {},
              ),
              const SizedBox(height: 16),
              MyToastWarning(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => {},
              ),
              const SizedBox(height: 16),
              MyToastError(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => {},
              ),
              const SizedBox(height: 16),
              MyDialog2(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed1: () => {},
                onPressed2: () => {},
                buttonText1: 'Button 1',
                buttonText2: 'Button 2',
              ),
              const SizedBox(height: 16),
              MyDialog3(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed1: () => {},
                onPressed2: () => {},
                onPressed3: () => {},
                buttonText1: 'Button 1',
                buttonText2: 'Button 2',
                buttonText3: 'Button 3',
              ),
              const SizedBox(height: 16),
              MyTooltip(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                isTop: true,
                horizontalOffset: 0.69,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  MyBadgeSymbol(symbol: '9'),
                  const SizedBox(width: 8),
                  MyBadgeIcon(icon: AppIcons.check),
                  const SizedBox(width: 8),
                  MyBadgeEmpty(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
