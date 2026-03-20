import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_selectable.dart';
import 'package:test_app/src/widgets/common/app_progress_bar.dart';
import 'package:test_app/src/features/themes/styles.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final _selectedInterests = ValueNotifier<Set<String>>({});

  late final _interestOptions = [
    context.l10n.userInterfaceLabel,
    context.l10n.userExperienceLabel,
    context.l10n.userResearchLabel,
    context.l10n.uxWritingLabel,
    context.l10n.userTestingLabel,
    context.l10n.serviceDesignLabel,
    context.l10n.strategyLabel,
    context.l10n.designSystemsLabel,
    context.l10n.prototypingLabel,
    context.l10n.accessibilityLabel,
    context.l10n.collaborationLabel,
    context.l10n.projectManagementLabel,
    context.l10n.innovationLabel,
    context.l10n.entrepreneurshipLabel,
    context.l10n.marketingLabel,
  ];

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
                fontSize: cMSize,
                fontWeight: cMWeight,
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
          child: Padding(
            padding: const EdgeInsets.all(spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing40,
              children: [
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder(
                      valueListenable: _selectedInterests,
                      builder: (context, selected, child) {
                        return AppProgressBar(
                          value: selected.length / _interestOptions.length,
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
                      context.l10n.personalizeYourExperienceLabel,
                      style: TextStyle(
                        fontSize: h1Size,
                        fontWeight: h1Weight,
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongestColor,
                      ),
                    ),
                    Text(
                      context.l10n.chooseYourInterestsLabel,
                      style: TextStyle(
                        fontSize: bSSize,
                        fontWeight: bSWeight,
                        color: Theme.of(
                          context,
                        ).extension<AppTheme>()?.foregroundStrongColor,
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

                          return AppListSelectable(
                            title: interest,
                            value: isSelected,
                            onChanged: (value) {
                              final newSelected = Set<String>.from(selected);
                              if (value == true) {
                                newSelected.add(interest);
                              } else {
                                newSelected.remove(interest);
                              }
                              _selectedInterests.value = newSelected;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppButtonPrimary(
                    text: context.l10n.nextLabel,
                    onPressed: () async {
                      await context.appController.updateUser(
                        (context.appState.user as AuthorizedUser).copyWith(
                              selectedInterests: _selectedInterests.value
                                  .toList(),
                            )
                            as AuthorizedUser,
                      );
                      if (!context.mounted) return;
                      context.go(homePath);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
