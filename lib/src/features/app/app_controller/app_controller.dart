import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/firebase_auth_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  final IFirebaseAuthRepository _authRepository;

  AppController()
    : _authRepository = FirebaseAuthRepositoryImpl(),
      super(
        state: const AppState.idle(
          message: 'initialized',
          user: UnauthorizedUser(),
        ),
        name: 'AppController',
      ) {
    // Don't listen to auth state changes on Windows due to threading issues
    // Instead, we'll check auth state after key actions
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      final user = await _authRepository.getCurrentUser();
      setState(AppState.idle(message: 'Auth initialized', user: user));
    } catch (e) {
      debugPrint('Failed to initialize auth state: $e');
    }
  }

  Future<void> register(String email, String password, String name) async {
    setState(AppState.processing(message: 'Registering...', user: state.user));

    // Run registration in background to avoid blocking the UI
    _performRegistration(email, password, name);
  }

  void _performRegistration(String email, String password, String name) {
    Future.microtask(() async {
      try {
        final user = await _authRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
          name: name,
        );
        setState(AppState.idle(message: 'Registration successful', user: user));
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Registration failed: ${error.toString()}',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<void> sendEmailVerification() async {
    setState(
      AppState.processing(
        message: 'Sending verification code...',
        user: state.user,
      ),
    );

    // Run in background
    _performSendEmailVerification();
  }

  void _performSendEmailVerification() {
    Future.microtask(() async {
      try {
        await _authRepository.sendEmailVerification();
        setState(
          AppState.idle(message: 'Verification code sent', user: state.user),
        );
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Failed to send verification code',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<void> login(String email, String password) async {
    setState(AppState.processing(message: 'Signing in...', user: state.user));

    // Run login in background
    _performLogin(email, password);
  }

  void _performLogin(String email, String password) {
    Future.microtask(() async {
      try {
        final user = await _authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(AppState.idle(message: 'Sign in successful', user: user));
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Sign in failed: ${error.toString()}',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<void> logout() async {
    setState(AppState.processing(message: 'Signing out...', user: state.user));

    // Run logout in background
    _performLogout();
  }

  void _performLogout() {
    Future.microtask(() async {
      try {
        await _authRepository.signOut();
        setState(
          AppState.idle(
            message: 'Sign out successful',
            user: const UnauthorizedUser(),
          ),
        );
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Sign out failed: ${error.toString()}',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<void> verifyEmailCode(String code) async {
    setState(
      AppState.processing(message: 'Verifying email code...', user: state.user),
    );

    // Run in background
    _performVerifyEmailCode(code);
  }

  void _performVerifyEmailCode(String code) {
    Future.microtask(() async {
      try {
        await _authRepository.verifyEmailCode(code: code);
        setState(
          AppState.idle(
            message: 'Email verified successfully',
            user: state.user,
          ),
        );
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Email verification failed',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  Future<void> resendEmailVerification() async {
    setState(
      AppState.processing(
        message: 'Resending verification code...',
        user: state.user,
      ),
    );

    // Run in background
    _performResendEmailVerification();
  }

  void _performResendEmailVerification() {
    Future.microtask(() async {
      try {
        await _authRepository.resendEmailVerification();
        setState(
          AppState.idle(message: 'Verification code resent', user: state.user),
        );
      } catch (error, stackTrace) {
        setState(
          AppState.failed(
            message: 'Failed to resend verification code',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
