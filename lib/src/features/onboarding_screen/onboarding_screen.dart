import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_pagination_dots.dart';
import 'package:test_app/src/widgets/common/app_progress_bar.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _selectedSection = ValueNotifier<int>(0);
  final _selectedSubScreen = ValueNotifier<int>(0);

  static const _interestOptions = [
    'User Interface',
    'User Experience',
    'User Research',
    'UX Writing',
    'User Testing',
    'Service Design',
    'Strategy',
    'Design Systems',
    'Prototyping',
    'Accessibility',
    'Collaboration',
    'Project Management',
    'Innovation',
    'Entrepreneurship',
    'Marketing',
  ];

  final _selectedInterests = ValueNotifier<Set<String>>({});

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
          child: ValueListenableBuilder(
            valueListenable: _selectedSubScreen,
            builder: (context, value, child) {
              return switch (value) {
                0 => Column(
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
                                    0 =>
                                      'Create a prototype in just a few minutes',
                                    1 =>
                                      'Collaborate with your team seamlessly',
                                    2 => 'Launch your product with confidence',
                                    _ =>
                                      'Create a prototype in just a few minutes',
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
                                onPressed: () {
                                  if (_selectedSection.value < 2) {
                                    _selectedSection.value++;
                                  } else {
                                    _selectedSubScreen.value = 1;
                                  }
                                },
                                text: 'Next',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                1 => Padding(
                  padding: const EdgeInsets.all(spacing24),
                  child: Column(
                    spacing: spacing40,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 327,
                          child: ValueListenableBuilder(
                            valueListenable: _selectedInterests,
                            builder: (context, selected, child) {
                              return AppProgressBar(
                                value:
                                    selected.length / _interestOptions.length,
                              );
                            },
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: spacing16,
                        children: [
                          Text(
                            'Personalise your experience',
                            style: TextStyle(
                              fontSize: h1Size,
                              fontWeight: h1Weight,
                              color: DarkColor.darkest.color,
                            ),
                          ),
                          Text(
                            'Choose your interests.',
                            style: TextStyle(
                              fontSize: bSSize,
                              fontWeight: bSWeight,
                              color: DarkColor.light.color,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _selectedInterests,
                          builder: (context, selected, child) {
                            return ListView.separated(
                              itemCount: _interestOptions.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: spacing8),
                              itemBuilder: (context, index) {
                                final interest = _interestOptions[index];
                                final isSelected = selected.contains(interest);

                                return SizedBox(
                                  width: 327,
                                  child: AppListItem(
                                    title: interest,
                                    control: AppListItemControl.checkbox,
                                    value: isSelected,
                                    onChanged: (value) {
                                      final newSelected = Set<String>.from(
                                        selected,
                                      );
                                      if (value == true) {
                                        newSelected.add(interest);
                                      } else {
                                        newSelected.remove(interest);
                                      }
                                      _selectedInterests.value = newSelected;
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AppButtonPrimary(
                          onPressed: () {
                            context.go(loginPath);
                          },
                          text: 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
                _ => SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _selectedSection.dispose();
    _selectedSubScreen.dispose();
    _selectedInterests.dispose();
    super.dispose();
  }
}
