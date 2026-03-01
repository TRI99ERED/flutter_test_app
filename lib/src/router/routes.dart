import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/home/home_screen.dart';
import 'package:test_app/src/features/onboarding/onboarding_screen.dart';
import 'package:test_app/src/features/login/login_screen.dart';

const homePath = '/';
const onboardingPath = '/onboarding';
const loginPath = '/login';
const registerPath = '/register';
const forgotPasswordPath = '/forgot-password';

GoRouter generateRouter() {
  return GoRouter(
    initialLocation: onboardingPath,
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
    ],
  );
}
