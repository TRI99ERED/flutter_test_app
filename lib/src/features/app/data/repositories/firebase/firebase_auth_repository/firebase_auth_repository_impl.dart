import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';

class GoogleSignInCanceledException implements Exception {
  final String message;
  GoogleSignInCanceledException([
    this.message = 'Sign-in was canceled by the user.',
  ]);
  @override
  String toString() => message;
}

class FirebaseAuthRepositoryImpl implements IFirebaseAuthRepository {
  @override
  Stream<UserEntity> get authStateChanges {
    return FirebaseAuth.instance
        .authStateChanges()
        .asyncMap((user) => _mapFirebaseUser(user))
        .handleError((Object error) {
          debugPrint('Auth state stream error (non-fatal): $error');
        });
  }

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
      return _mapFirebaseUserToAuthorizedWithFirestore(credential.user!);
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
  Future<AuthorizedUser?> signInWithGoogle() async {
    try {
      final String? clientId = kIsWeb
          ? '503645418605-m55u2bsiqj2edouhrmdhmf66gbd6jrsp.apps.googleusercontent.com'
          : Platform.isIOS
          ? '503645418605-up6nflc7f9a7f1oueo1n1hepopu1sc25.apps.googleusercontent.com'
          : Platform.isAndroid
          ? '503645418605-c9hi3up5de2qhbn3u75f6ffsuidfue70.apps.googleusercontent.com'
          : null;

      const String? serverClientId = kIsWeb
          ? null
          : '503645418605-m55u2bsiqj2edouhrmdhmf66gbd6jrsp.apps.googleusercontent.com';

      if (!kIsWeb) {
        final GoogleSignIn signIn = GoogleSignIn.instance;
        final completer = Completer<GoogleSignInAccount?>();
        StreamSubscription? sub;
        await signIn.initialize(
          clientId: clientId,
          serverClientId: serverClientId,
        );
        sub = signIn.authenticationEvents.listen(
          (event) async {
            final user = switch (event) {
              GoogleSignInAuthenticationEventSignIn() => event.user,
              GoogleSignInAuthenticationEventSignOut() => null,
            };
            if (!completer.isCompleted) {
              completer.complete(user);
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              if (error is GoogleSignInException &&
                  error.code == GoogleSignInExceptionCode.canceled) {
                completer.completeError(GoogleSignInCanceledException());
              } else {
                completer.completeError(
                  Exception('Google Sign-In authentication error: $error'),
                );
              }
            }
          },
        );
        signIn.authenticate();
        final GoogleSignInAccount? user;
        try {
          user = await completer.future;
        } on GoogleSignInCanceledException {
          await sub.cancel();
          throw GoogleSignInCanceledException();
        }
        await sub.cancel();
        if (user != null) {
          final googleAuth = user.authentication;
          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
          );
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          return _mapFirebaseUserToAuthorizedWithFirestore(
            userCredential.user!,
          );
        } else {
          return null;
        }
      } else {
        throw UnimplementedError(
          'On web, use GoogleSignIn().renderButton() in the UI and handle sign-in there.',
        );
      }
    } catch (e) {
      if (e is GoogleSignInCanceledException) rethrow;
      throw Exception('Google Sign-In failed: $e');
    }
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

      return _mapFirebaseUserToAuthorizedWithFirestore(
        FirebaseAuth.instance.currentUser!,
      );
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
      return _mapFirebaseUserToAuthorizedWithFirestore(
        FirebaseAuth.instance.currentUser!,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<AuthorizedUser> watchAuthState() {
    return FirebaseAuth.instance
        .authStateChanges()
        .asyncMap((user) {
          if (user == null) {
            return Future<AuthorizedUser>.error('User is not authorized');
          }
          return _mapFirebaseUserToAuthorizedWithFirestore(user);
        })
        .handleError((Object error) {
          debugPrint('Auth state stream error (non-fatal): $error');
        });
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

  Future<UserEntity> _mapFirebaseUser(User? user) async {
    if (user == null) {
      return const UnauthorizedUser();
    }
    return await _mapFirebaseUserToAuthorizedWithFirestore(user);
  }

  Future<AuthorizedUser> _mapFirebaseUserToAuthorizedWithFirestore(
    User user,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};
    return AuthorizedUser(
      id: user.uid,
      name:
          data['name'] ??
          user.displayName ??
          'user_${user.uid.substring(0, 8)}',
      email: data['email'] ?? user.email ?? '',
      handle: data['handle'] ?? '',
      avatarUrl: data['avatarUrl'] ?? user.photoURL ?? '',
    );
  }
}
