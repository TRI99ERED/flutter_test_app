import 'package:flutter/material.dart';
import 'package:test_app/src/features/splash_screen/splash_screen.dart';
import 'package:test_app/src/features/appearance_screen/appearance_screen.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';
import 'package:test_app/src/features/email_confirmation_screen/email_confirmation_screen.dart';
import 'package:test_app/src/features/forgot_password_screen/forgot_password_screen.dart';
import 'package:test_app/src/features/home_screen/home_screen.dart';
import 'package:test_app/src/features/interests_screen/interests_screen.dart';
import 'package:test_app/src/features/language_screen/language_screen.dart';
import 'package:test_app/src/features/login_screen/login_screen.dart';
import 'package:test_app/src/features/notifications_screen/notifications_screen.dart';
import 'package:test_app/src/features/onboarding_screen/onboarding_screen.dart';
import 'package:test_app/src/features/project_feedback_screen/project_feedback_screen.dart';
import 'package:test_app/src/features/project_screen/project_screen.dart';
import 'package:test_app/src/features/register_screen/register_screen.dart';
import 'package:test_app/src/features/saved_messages_screen/saved_messages_screen.dart';

/// Type alias for the navigation state, which is a list of [AppPage] instances.
typedef AppNavigationState = List<AppPage>;

/// Base class for all application pages.
///
/// Extends [MaterialPage] directly so each page IS a [Page] — no wrapper
/// needed. Subclasses can override [createRoute] to customise transitions,
/// hero animations, or any per-page routing behaviour.
abstract class AppPage extends MaterialPage<void> {
  const AppPage({
    required super.child,
    required super.key,
    required super.name,
  });

  /// Path representation used for deep-link matching and URL sync.
  String get path;

  @override
  String toString() => 'AppPage($name)';
}

// ---------------------------------------------------------------------------
// Splash
// ---------------------------------------------------------------------------

class SplashPage extends AppPage {
  const SplashPage()
      : super(
          key: const ValueKey('SplashPage'),
          name: 'Splash',
          child: const SplashScreen(),
        );

  @override
  String get path => '/splash';
}

// ---------------------------------------------------------------------------
// Auth flow pages
// ---------------------------------------------------------------------------

class OnboardingPage extends AppPage {
  const OnboardingPage()
      : super(
          key: const ValueKey('OnboardingPage'),
          name: 'Onboarding',
          child: const OnboardingScreen(),
        );

  @override
  String get path => '/onboarding';
}

class LoginPage extends AppPage {
  const LoginPage()
      : super(
          key: const ValueKey('LoginPage'),
          name: 'Login',
          child: const LoginScreen(),
        );

  @override
  String get path => '/login';
}

class RegisterPage extends AppPage {
  const RegisterPage()
      : super(
          key: const ValueKey('RegisterPage'),
          name: 'Register',
          child: const RegisterScreen(),
        );

  @override
  String get path => '/register';
}

class EmailConfirmationPage extends AppPage {
  const EmailConfirmationPage()
      : super(
          key: const ValueKey('EmailConfirmationPage'),
          name: 'EmailConfirmation',
          child: const EmailConfirmationScreen(),
        );

  @override
  String get path => '/email-confirmation';
}

class ForgotPasswordPage extends AppPage {
  const ForgotPasswordPage()
      : super(
          key: const ValueKey('ForgotPasswordPage'),
          name: 'ForgotPassword',
          child: const ForgotPasswordScreen(),
        );

  @override
  String get path => '/forgot-password';
}

class InterestsPage extends AppPage {
  const InterestsPage()
      : super(
          key: const ValueKey('InterestsPage'),
          name: 'Interests',
          child: const InterestsScreen(),
        );

  @override
  String get path => '/interests';
}

// ---------------------------------------------------------------------------
// Main app pages
// ---------------------------------------------------------------------------

class HomePage extends AppPage {
  final int initialTab;
  final int initialFriendsSection;
  final int initialProjectsSection;

  HomePage({
    this.initialTab = 0,
    this.initialFriendsSection = 0,
    this.initialProjectsSection = 0,
  }) : super(
          key: const ValueKey('HomePage'),
          name: 'Home',
          child: HomeScreen(
            initialTab: initialTab,
            initialFriendsSection: initialFriendsSection,
            initialProjectsSection: initialProjectsSection,
          ),
        );

  @override
  String get path => '/';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomePage &&
          initialTab == other.initialTab &&
          initialFriendsSection == other.initialFriendsSection &&
          initialProjectsSection == other.initialProjectsSection;

  @override
  int get hashCode =>
      Object.hash(runtimeType, initialTab, initialFriendsSection, initialProjectsSection);
}

class ChatPage extends AppPage {
  final String chatId;
  final ChatType chatType;

  ChatPage({required this.chatId, required this.chatType})
      : super(
          key: ValueKey('ChatPage_${chatType.name}_$chatId'),
          name: 'Chat',
          child: ChatScreen(chatId: chatId, chatType: chatType),
        );

  @override
  String get path => '/chats/${chatType.name}/$chatId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatPage && chatId == other.chatId && chatType == other.chatType;

  @override
  int get hashCode => Object.hash(chatId, chatType);
}

class ProjectPage extends AppPage {
  final String projectId;

  ProjectPage({required this.projectId})
      : super(
          key: ValueKey('ProjectPage_$projectId'),
          name: 'Project',
          child: ProjectScreen(projectId: projectId),
        );

  @override
  String get path => '/projects/$projectId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPage && projectId == other.projectId;

  @override
  int get hashCode => projectId.hashCode;
}

class ProjectFeedbackPage extends AppPage {
  final String projectId;

  ProjectFeedbackPage({required this.projectId})
      : super(
          key: ValueKey('ProjectFeedbackPage_$projectId'),
          name: 'ProjectFeedback',
          child: ProjectFeedbackScreen(projectId: projectId),
        );

  @override
  String get path => '/projects/$projectId/feedback';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFeedbackPage && projectId == other.projectId;

  @override
  int get hashCode => projectId.hashCode;
}

class SavedMessagesPage extends AppPage {
  const SavedMessagesPage()
      : super(
          key: const ValueKey('SavedMessagesPage'),
          name: 'SavedMessages',
          child: const SavedMessagesScreen(),
        );

  @override
  String get path => '/saved-messages';
}

class NotificationsPage extends AppPage {
  const NotificationsPage()
      : super(
          key: const ValueKey('NotificationsPage'),
          name: 'Notifications',
          child: const NotificationsScreen(),
        );

  @override
  String get path => '/notifications';
}

class AppearancePage extends AppPage {
  const AppearancePage()
      : super(
          key: const ValueKey('AppearancePage'),
          name: 'Appearance',
          child: const AppearanceScreen(),
        );

  @override
  String get path => '/appearance';
}

class LanguagePage extends AppPage {
  const LanguagePage()
      : super(
          key: const ValueKey('LanguagePage'),
          name: 'Language',
          child: const LanguageScreen(),
        );

  @override
  String get path => '/language';
}
