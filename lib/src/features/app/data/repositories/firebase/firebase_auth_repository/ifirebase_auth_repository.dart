import 'package:test_app/src/features/app/data/models/user_model.dart';

/// Interface for Firebase Authentication operations
abstract interface class IFirebaseAuthRepository {
  /// Get the current authenticated user
  /// Returns [AuthorizedUser] if signed in, [UnauthorizedUser] otherwise
  Future<UserEntity> getCurrentUser();

  /// Sign in with email and password
  /// Returns [AuthorizedUser] on success
  /// Throws exception on failure
  Future<AuthorizedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new user account with email and password
  /// Returns [AuthorizedUser] on success
  /// Throws exception on failure
  Future<AuthorizedUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in with Google account
  /// Returns [AuthorizedUser] on success
  /// Throws exception on failure or if user cancels
  Future<AuthorizedUser> signInWithGoogle();

  /// Sign in with Facebook account
  /// Returns [AuthorizedUser] on success
  /// Throws exception on failure or if user cancels
  Future<AuthorizedUser> signInWithFacebook();

  /// Sign in with Apple account
  /// Returns [AuthorizedUser] on success
  /// Throws exception on failure or if user cancels
  Future<AuthorizedUser> signInWithApple();

  /// Sign out the current user
  /// Returns [UnauthorizedUser] after successful sign out
  Future<void> signOut();

  /// Send password reset email
  /// Throws exception on failure
  Future<void> sendPasswordResetEmail({required String email});

  /// Update user profile (name and/or avatar URL)
  /// Returns updated [AuthorizedUser]
  Future<AuthorizedUser> updateUserProfile({String? name, String? avatarUrl});

  /// Delete the current user account
  /// Returns [UnauthorizedUser] after deletion
  /// Throws exception on failure (may require recent authentication)
  Future<void> deleteAccount();

  /// Reauthenticate user with password (required for sensitive operations)
  /// Throws exception on failure
  Future<void> reauthenticateWithPassword({required String password});

  /// Send email verification to current user
  /// Throws exception if user is not signed in
  Future<void> sendEmailVerification();

  /// Check if current user's email is verified
  Future<bool> isEmailVerified();
}
