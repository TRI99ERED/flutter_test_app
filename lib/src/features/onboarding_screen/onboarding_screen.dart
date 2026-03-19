import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_pagination_dots.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/features/themes/styles.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongColor,
            content: Text(
              '${context.l10n.errorLabel}: ${current.message}',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
          ),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: PlaceholderImage()),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.5,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundStrongestColor,
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
                              0 =>
                                context
                                    .l10n
                                    .createAPrototypeInJustAFewMinutesLabel,
                              1 =>
                                context
                                    .l10n
                                    .collaborateWithYourTeamSeamlesslyLabel,
                              2 =>
                                context
                                    .l10n
                                    .launchYourProjectWithConfidenceLabel,
                              _ =>
                                context
                                    .l10n
                                    .createAPrototypeInJustAFewMinutesLabel,
                            },
                            style: TextStyle(
                              fontSize: h1Size,
                              fontWeight: h1Weight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundStrongestColor,
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
                                context.l10n.enjoyThesePreMadeComponentsLabel,
                              1 => context.l10n.workTogetherWithYourTeamLabel,
                              2 =>
                                context
                                    .l10n
                                    .launchYourProjectWithConfidenceAndEaseLabel,
                              _ =>
                                context.l10n.enjoyThesePreMadeComponentsLabel,
                            },
                            style: TextStyle(
                              fontSize: bSSize,
                              fontWeight: bSWeight,
                              color: Theme.of(
                                context,
                              ).extension<AppTheme>()?.foregroundWeakColor,
                            ),
                            textAlign: TextAlign.start,
                          );
                        },
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonPrimary(
                          text: context.l10n.nextLabel,
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
