import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';

class FirebaseAuthRepositoryImpl implements IFirebaseAuthRepository {
  @override
  Stream<UserEntity> get authStateChanges {
    return FirebaseAuth.instance
        .authStateChanges()
        .map((user) => _mapFirebaseUser(user))
        .handleError((Object error) {
          debugPrint('Auth state stream error (non-fatal): $error');
        });
  }

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'europe-central2');

  @override
  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    return _mapFirebaseUser(user);
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    await user.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> reauthenticateWithPassword({required String password}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _functions.httpsCallable('sendEmailVerificationCode').call();
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _functions.httpsCallable('sendEmailVerificationCode').call();
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AuthorizedUser> signInWithApple() async {
    throw UnimplementedError(
      'Apple Sign-In requires sign_in_with_apple package',
    );
  }

  @override
  Future<AuthorizedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUserToAuthorized(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AuthorizedUser> signInWithFacebook() async {
    throw UnimplementedError(
      'Facebook Sign-In requires flutter_facebook_auth package',
    );
  }

  @override
  Future<AuthorizedUser> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In requires google_sign_in package');
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<AuthorizedUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user != null && name.isNotEmpty) {
        try {
          await user.updateDisplayName(name);
        } catch (e) {
          debugPrint('Failed to set display name: $e');
        }
      }

      return _mapFirebaseUserToAuthorized(FirebaseAuth.instance.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AuthorizedUser> updateUserProfile({
    String? name,
    String? avatarUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }
      await user.reload();
      return _mapFirebaseUserToAuthorized(FirebaseAuth.instance.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> verifyEmailCode({required String code}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _functions.httpsCallable('verifyEmailVerificationCode').call({
        'code': code,
      });

      await user.reload();
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'weak-password':
        return Exception('The password is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Please try again later.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'requires-recent-login':
        return Exception(
          'This operation requires recent authentication. Please sign in again.',
        );
      default:
        return Exception(e.message ?? 'An authentication error occurred.');
    }
  }

  Exception _handleFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return Exception(e.message ?? 'The verification code is invalid.');
      case 'not-found':
        return Exception(
          e.message ?? 'No active verification code found. Please resend.',
        );
      case 'deadline-exceeded':
        return Exception(
          e.message ??
              'The verification code has expired. Please request a new code.',
        );
      case 'permission-denied':
        return Exception(
          e.message ??
              'Too many failed attempts. Please request a new verification code.',
        );
      case 'unauthenticated':
        return Exception(e.message ?? 'Please sign in again and try.');
      default:
        return Exception(
          e.message ??
              'A verification service error occurred. Please try again.',
        );
    }
  }

  UserEntity _mapFirebaseUser(User? user) {
    if (user == null) {
      return const UnauthorizedUser();
    }
    return _mapFirebaseUserToAuthorized(user);
  }

  AuthorizedUser _mapFirebaseUserToAuthorized(User user) {
    return AuthorizedUser(
      id: user.uid,
      name: user.displayName ?? 'user_${user.uid.substring(0, 8)}',
      email: user.email ?? '',
      handle: user.displayName != null
          ? user.displayName!.toLowerCase().replaceAll(' ', '')
          : 'user_${user.uid.substring(0, 8)}',
      avatarUrl: user.photoURL ?? '',
    );
  }
}
