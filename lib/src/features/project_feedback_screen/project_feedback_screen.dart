import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_star_rating.dart';
import 'package:test_app/src/widgets/common/app_tag.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/widgets/common/styles.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: DarkColor.darkest.color,
                    ),
                  ),
                  Text(
                    'How would you rate the prototyping kit?',
                    style: TextStyle(
                      fontSize: bMSize,
                      fontWeight: bMWeight,
                      color: DarkColor.light.color,
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
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing16,
                children: [
                  Text(
                    'What did you like about it?',
                    style: TextStyle(
                      fontSize: h5Size,
                      fontWeight: h5Weight,
                      color: DarkColor.darkest.color,
                    ),
                  ),
                  Wrap(
                    spacing: spacing8,
                    runSpacing: spacing8,
                    children: [
                      AppTag(
                        text: 'EASY TO USE',
                        onPressed: () {
                          _likes.value = {..._likes.value, 'EASY TO USE'};
                        },
                      ),
                      AppTag(
                        text: 'COMPLETE',
                        onPressed: () {
                          _likes.value = {..._likes.value, 'COMPLETE'};
                        },
                      ),
                      AppTag(
                        text: 'HELPFUL',
                        onPressed: () {
                          _likes.value = {..._likes.value, 'HELPFUL'};
                        },
                      ),
                      AppTag(
                        text: 'CONVENIENT',
                        onPressed: () {
                          _likes.value = {..._likes.value, 'CONVENIENT'};
                        },
                      ),
                      AppTag(
                        text: 'LOOKS GOOD',
                        onPressed: () {
                          _likes.value = {..._likes.value, 'LOOKS GOOD'};
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing16,
                children: [
                  Text(
                    'What could be improved?',
                    style: TextStyle(
                      fontSize: h5Size,
                      fontWeight: h5Weight,
                      color: DarkColor.darkest.color,
                    ),
                  ),
                  Wrap(
                    spacing: spacing8,
                    runSpacing: spacing8,
                    children: [
                      AppTag(
                        text: 'COULD HAVE MORE COMPONENTS',
                        onPressed: () {
                          _dislikes.value = {
                            ..._dislikes.value,
                            'COULD HAVE MORE COMPONENTS',
                          };
                        },
                      ),
                      AppTag(
                        text: 'COMPLEX',
                        onPressed: () {
                          _dislikes.value = {..._dislikes.value, 'COMPLEX'};
                        },
                      ),
                      AppTag(
                        text: 'NOT INTERACTIVE',
                        onPressed: () {
                          _dislikes.value = {
                            ..._dislikes.value,
                            'NOT INTERACTIVE',
                          };
                        },
                      ),
                      AppTag(
                        text: 'ONLY ENGLISH',
                        onPressed: () {
                          _dislikes.value = {
                            ..._dislikes.value,
                            'ONLY ENGLISH',
                          };
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing16,
                children: [
                  Text(
                    'Anything else?',
                    style: TextStyle(
                      fontSize: h5Size,
                      fontWeight: h5Weight,
                      color: DarkColor.darkest.color,
                    ),
                  ),
                  AppTextArea(
                    placeholder: 'Tell us everything.',
                    controller: _feedbackController,
                  ),
                ],
              ),
              Spacer(),
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
