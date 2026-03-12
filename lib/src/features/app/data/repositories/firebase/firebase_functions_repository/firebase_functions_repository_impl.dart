import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_functions_repository/ifirebase_functions_repository.dart';

class FirebaseFunctionsRepositoryImpl implements IFirebaseFunctionsRepository {
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
      throw Exception('Email verification failed: {e.toString()}');
    }
  }

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'europe-central2');

  @override
  Future<String> uploadGroupAvatar({
    required String chatId,
    required String filename,
    required Uint8List avatarBytes,
  }) async {
    final callable = _functions.httpsCallable('uploadGroupAvatar');
    final avatarBase64 = base64Encode(avatarBytes);
    try {
      final result = await callable.call({
        'chatId': chatId,
        'filename': filename,
        'avatarBase64': avatarBase64,
      });
      return result.data['url'] as String;
    } catch (e) {
      throw Exception('Failed to upload group avatar: $e');
    }
  }

  @override
  Future<void> deleteGroupAvatar({
    required String chatId,
    required String filename,
  }) async {
    final callable = _functions.httpsCallable('deleteGroupAvatar');
    try {
      await callable.call({'chatId': chatId, 'filename': filename});
    } catch (e) {
      throw Exception('Failed to delete group avatar: $e');
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
}
