import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_star_rating.dart';
import 'package:test_app/src/widgets/common/app_tag.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/features/themes/styles.dart';

class ProjectFeedbackScreen extends StatefulWidget {
  final String projectId;

  const ProjectFeedbackScreen({super.key, required this.projectId});

  @override
  State<ProjectFeedbackScreen> createState() => _ProjectFeedbackScreenState();
}

class _ProjectFeedbackScreenState extends State<ProjectFeedbackScreen> {
  final _starRating = ValueNotifier<int>(0);
  final _likes = ValueNotifier<Set<String>>({});
  final _dislikes = ValueNotifier<Set<String>>({});
  final _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) => !previous.isFailed && current.isFailed,
      listener: (context, previous, current) {
        if (current.isFailed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
        }
      },
      child: Scaffold(
        appBar: AppNavBar(
          title: 'Feedback',
          leftIcon: AppIcons.arrowLeft,
          onPressedLeft: () {
            context.pop();
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(spacing24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing20,
                      children: [
                        Text(
                          'Your project is finished.',
                          style: TextStyle(
                            fontSize: h2Size,
                            fontWeight: h2Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        Text(
                          'How would you rate the prototyping kit?',
                          style: TextStyle(
                            fontSize: bMSize,
                            fontWeight: bMWeight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundWeakColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _starRating,
                            builder: (context, value, child) {
                              return AppStarRating(
                                rating: value,
                                onRatingChanged: (newValue) {
                                  _starRating.value = newValue;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing16,
                      children: [
                        Text(
                          'What did you like about it?',
                          style: TextStyle(
                            fontSize: h5Size,
                            fontWeight: h5Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        Wrap(
                          spacing: spacing8,
                          runSpacing: spacing8,
                          children: [
                            AppTag(
                              text: 'EASY TO USE',
                              onChanged: (value) {
                                if (value) {
                                  _likes.value = {
                                    ..._likes.value,
                                    'EASY TO USE',
                                  };
                                } else {
                                  _likes.value = _likes.value
                                      .where((e) => e != 'EASY TO USE')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'COMPLETE',
                              onChanged: (value) {
                                if (value) {
                                  _likes.value = {..._likes.value, 'COMPLETE'};
                                } else {
                                  _likes.value = _likes.value
                                      .where((e) => e != 'COMPLETE')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'HELPFUL',
                              onChanged: (value) {
                                if (value) {
                                  _likes.value = {..._likes.value, 'HELPFUL'};
                                } else {
                                  _likes.value = _likes.value
                                      .where((e) => e != 'HELPFUL')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'CONVENIENT',
                              onChanged: (value) {
                                if (value) {
                                  _likes.value = {
                                    ..._likes.value,
                                    'CONVENIENT',
                                  };
                                } else {
                                  _likes.value = _likes.value
                                      .where((e) => e != 'CONVENIENT')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'LOOKS GOOD',
                              onChanged: (value) {
                                if (value) {
                                  _likes.value = {
                                    ..._likes.value,
                                    'LOOKS GOOD',
                                  };
                                } else {
                                  _likes.value = _likes.value
                                      .where((e) => e != 'LOOKS GOOD')
                                      .toSet();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing16,
                      children: [
                        Text(
                          'What could be improved?',
                          style: TextStyle(
                            fontSize: h5Size,
                            fontWeight: h5Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        Wrap(
                          spacing: spacing8,
                          runSpacing: spacing8,
                          children: [
                            AppTag(
                              text: 'COULD HAVE MORE COMPONENTS',
                              onChanged: (value) {
                                if (value) {
                                  _dislikes.value = {
                                    ..._dislikes.value,
                                    'COULD HAVE MORE COMPONENTS',
                                  };
                                } else {
                                  _dislikes.value = _dislikes.value
                                      .where(
                                        (e) =>
                                            e != 'COULD HAVE MORE COMPONENTS',
                                      )
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'COMPLEX',
                              onChanged: (value) {
                                if (value) {
                                  _dislikes.value = {
                                    ..._dislikes.value,
                                    'COMPLEX',
                                  };
                                } else {
                                  _dislikes.value = _dislikes.value
                                      .where((e) => e != 'COMPLEX')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'NOT INTERACTIVE',
                              onChanged: (value) {
                                if (value) {
                                  _dislikes.value = {
                                    ..._dislikes.value,
                                    'NOT INTERACTIVE',
                                  };
                                } else {
                                  _dislikes.value = _dislikes.value
                                      .where((e) => e != 'NOT INTERACTIVE')
                                      .toSet();
                                }
                              },
                            ),
                            AppTag(
                              text: 'ONLY ENGLISH',
                              onChanged: (value) {
                                if (value) {
                                  _dislikes.value = {
                                    ..._dislikes.value,
                                    'ONLY ENGLISH',
                                  };
                                } else {
                                  _dislikes.value = _dislikes.value
                                      .where((e) => e != 'ONLY ENGLISH')
                                      .toSet();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing16,
                      children: [
                        Text(
                          'Anything else?',
                          style: TextStyle(
                            fontSize: h5Size,
                            fontWeight: h5Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        AppTextArea(
                          placeholder: 'Tell us everything.',
                          controller: _feedbackController,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(spacing24),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButtonPrimary(
                    text: 'Submit',
                    onPressed: () async {
                      await context.appController.submitProjectFeedback(
                        projectId: widget.projectId,
                        userId: (context.appState.user as AuthorizedUser).id,
                        starRating: _starRating.value,
                        likes: _likes.value,
                        dislikes: _dislikes.value,
                        feedback: _feedbackController.text,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback submitted!')),
                      );
                    },
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
    _starRating.dispose();
    _likes.dispose();
    _dislikes.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}
