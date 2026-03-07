import 'package:test_app/src/features/app/data/models/user_model.dart';

abstract interface class IFirebaseAuthRepository {
  Stream<UserEntity> get authStateChanges;

  Future<UserEntity> getCurrentUser();

  Future<AuthorizedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthorizedUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthorizedUser> signInWithGoogle();

  Future<AuthorizedUser> signInWithFacebook();

  Future<AuthorizedUser> signInWithApple();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<AuthorizedUser> updateUserProfile({String? name, String? avatarUrl});

  Future<void> deleteAccount();

  Future<void> reauthenticateWithPassword({required String password});

  Future<void> sendEmailVerification();

  Future<bool> isEmailVerified();

  Future<void> verifyEmailCode({required String code});

  Future<void> resendEmailVerification();
}
