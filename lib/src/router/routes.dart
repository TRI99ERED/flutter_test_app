import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/appearance_screen/appearance_screen.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/features/email_confirmation_screen/email_confirmation_screen.dart';
import 'package:test_app/src/features/forgot_password_screen/forgot_password_screen.dart';
import 'package:test_app/src/features/home_screen/home_screen.dart';
import 'package:test_app/src/features/interests_screen/interests_screen.dart';
import 'package:test_app/src/features/language_screen/language_screen.dart';
import 'package:test_app/src/features/notifications_screen/notifications_screen.dart';
import 'package:test_app/src/features/onboarding_screen/onboarding_screen.dart';
import 'package:test_app/src/features/login_screen/login_screen.dart';
import 'package:test_app/src/features/project_feedback_screen/project_feedback_screen.dart';
import 'package:test_app/src/features/project_screen/project_screen.dart';
import 'package:test_app/src/features/register_screen/register_screen.dart';
import 'package:test_app/src/features/saved_messages_screen/saved_messages_screen.dart';

const homePath = '/';
const onboardingPath = '/onboarding';
const loginPath = '/login';
const registerPath = '/register';
const interestsPath = '/interests';
const emailConfirmationPath = '/email-confirmation';
const forgotPasswordPath = '/forgot-password';
const chatPath = '/chats/:chatType/:chatId';
const incomingFriendRequestsPath = '/friends/incoming';
const projectPath = '/projects/:projectId';
const projectFeedbackPath = '/projects/:projectId/feedback';
const savedMessagesPath = '/saved-messages';
const notificationsPath = '/notifications';
const appearancePath = '/appearance';
const languagePath = '/language';

GoRouter generateRouter(
  AppController appController,
  GlobalKey<NavigatorState> rootNavigatorKey,
) {
  return GoRouter(
    initialLocation: onboardingPath,
    refreshListenable: appController,
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: homePath, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: interestsPath,
        builder: (context, state) => const InterestsScreen(),
      ),
      GoRoute(
        path: emailConfirmationPath,
        builder: (context, state) => const EmailConfirmationScreen(),
      ),
      GoRoute(
        path: forgotPasswordPath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: chatPath,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final chatType = state.pathParameters['chatType'] ?? 'direct';
          return ChatScreen(
            chatId: chatId,
            chatType: chatType == 'group' ? ChatType.group : ChatType.direct,
          );
        },
      ),
      GoRoute(
        path: incomingFriendRequestsPath,
        builder: (context, state) {
          return const HomeScreen(initialTab: 1, initialFriendsSection: 1);
        },
      ),
      GoRoute(
        path: projectPath,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: projectFeedbackPath,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectFeedbackScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: savedMessagesPath,
        builder: (context, state) {
          return const SavedMessagesScreen();
        },
      ),
      GoRoute(
        path: notificationsPath,
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),
      GoRoute(
        path: appearancePath,
        builder: (context, state) {
          return const AppearanceScreen();
        },
      ),
      GoRoute(
        path: languagePath,
        builder: (context, state) {
          return const LanguageScreen();
        },
      ),
    ],
    redirect: (context, state) async {
      final isAuthorized = context.appState.isAuthorized;
      final location = state.matchedLocation;

      if (!isAuthorized && location == homePath) {
        return loginPath;
      }

      if (isAuthorized &&
          (location == onboardingPath ||
              location == loginPath ||
              location == registerPath)) {
        return homePath;
      }

      return null;
    },
  );
}
