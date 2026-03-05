import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/email_confirmation_screen/email_confirmation_screen.dart';
import 'package:test_app/src/features/home_screen/home_screen.dart';
import 'package:test_app/src/features/onboarding_screen/onboarding_screen.dart';
import 'package:test_app/src/features/login_screen/login_screen.dart';
import 'package:test_app/src/features/register_screen/register_screen.dart';

const homePath = '/';
const onboardingPath = '/onboarding';
const loginPath = '/login';
const registerPath = '/register';
const emailConfirmationPath = '/email-confirmation';
const forgotPasswordPath = '/forgot-password';

GoRouter generateRouter(AppController appController) {
  return GoRouter(
    initialLocation: onboardingPath,
    refreshListenable: appController,
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
        path: emailConfirmationPath,
        builder: (context, state) => const EmailConfirmationScreen(),
      ),
    ],
    redirect: (context, state) {
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
