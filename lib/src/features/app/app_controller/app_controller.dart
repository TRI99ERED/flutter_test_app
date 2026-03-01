import 'dart:async';

import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/firebase_auth_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  final IFirebaseAuthRepository _authRepository;
  StreamSubscription<UserEntity>? _authSubscription;

  AppController()
    : _authRepository = FirebaseAuthRepositoryImpl(),
      super(
        state: const AppState.idle(
          message: 'initialized',
          user: UnauthorizedUser(),
        ),
        name: 'AppController',
      ) {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      setState(AppState.idle(message: 'Auth updated', user: user));
    });
  }

  Future<void> register(String email, String password, String name) async {
    setState(AppState.processing(message: 'Registering...', user: state.user));
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      setState(
        AppState.failed(
          message: 'Registration failed',
          user: state.user,
          error: e,
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    setState(AppState.processing(message: 'Signing in...', user: state.user));
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      setState(
        AppState.failed(message: 'Sign in failed', user: state.user, error: e),
      );
    }
  }

  Future<void> logout() async {
    setState(AppState.processing(message: 'Signing out...', user: state.user));
    try {
      await _authRepository.signOut();
    } catch (e) {
      setState(
        AppState.failed(message: 'Sign out failed', user: state.user, error: e),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
