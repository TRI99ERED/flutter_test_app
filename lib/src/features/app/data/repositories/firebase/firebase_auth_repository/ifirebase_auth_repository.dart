import 'package:test_app/src/features/app/data/models/user_model.dart';

abstract interface class IFirebaseAuthRepository {
  Stream<UserEntity> get authStateChanges;

  Future<void> deleteAccount();

  Future<UserEntity> getCurrentUser();

  Future<bool> isEmailVerified();

  Future<void> reauthenticateWithPassword({required String password});

  Future<void> resendEmailVerification();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail({required String email});

  Future<AuthorizedUser> signInWithApple();

  Future<AuthorizedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthorizedUser> signInWithFacebook();

  Future<AuthorizedUser> signInWithGoogle();

  Future<void> signOut();

  Future<AuthorizedUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthorizedUser> updateUserProfile({String? name, String? avatarUrl});

  Future<void> verifyEmailCode({required String code});
}
