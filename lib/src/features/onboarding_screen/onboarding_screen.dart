import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_pagination_dots.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _selectedSection = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasSeenOnboarding = await context.appController.hasSeenOnboarding();
      if (!mounted) return;
      if (hasSeenOnboarding) {
        context.go(loginPath);
        return;
      }
      context.appController.setHasSeenOnboarding(true);
    });
  }

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
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: PlaceholderImage()),
              Container(
                height: 350,
                color: LightColor.lightest.color,
                child: Padding(
                  padding: const EdgeInsets.all(spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing32,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _selectedSection,
                        builder: (context, selectedSection, child) {
                          return AppPaginationDots(
                            dotCount: 3,
                            activeIndex: selectedSection,
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedSection,
                        builder: (context, value, child) {
                          return Text(
                            switch (_selectedSection.value) {
                              0 => 'Create a prototype in just a few minutes',
                              1 => 'Collaborate with your team seamlessly',
                              2 => 'Launch your product with confidence',
                              _ => 'Create a prototype in just a few minutes',
                            },
                            style: TextStyle(
                              fontSize: h1Size,
                              fontWeight: h1Weight,
                              color: DarkColor.darkest.color,
                            ),
                            textAlign: TextAlign.start,
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedSection,
                        builder: (context, value, child) {
                          return Text(
                            switch (_selectedSection.value) {
                              0 =>
                                'Enjoy these pre-made components and worry only about creating the best product ever.',
                              1 =>
                                'Work together with your team seamlessly and efficiently.',
                              2 =>
                                'Launch your product with confidence and ease.',
                              _ =>
                                'Enjoy these pre-made components and worry only about creating the best product ever.',
                            },
                            style: TextStyle(
                              fontSize: bSSize,
                              fontWeight: bSWeight,
                              color: DarkColor.light.color,
                            ),
                            textAlign: TextAlign.start,
                          );
                        },
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonPrimary(
                          text: 'Next',
                          onPressed: () {
                            if (_selectedSection.value < 2) {
                              _selectedSection.value++;
                            } else {
                              context.go(loginPath);
                            }
                          },
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
    _selectedSection.dispose();
    super.dispose();
  }
}
