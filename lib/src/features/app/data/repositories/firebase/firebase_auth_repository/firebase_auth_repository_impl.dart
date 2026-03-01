import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';

class FirebaseAuthRepositoryImpl implements IFirebaseAuthRepository {
  @override
  Stream<UserEntity> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges().map(
      (user) => _mapFirebaseUser(user),
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    return _mapFirebaseUser(user);
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
  Future<AuthorizedUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();

      return _mapFirebaseUserToAuthorized(FirebaseAuth.instance.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AuthorizedUser> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // You'll need to add google_sign_in package and configure it
    // Example:
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // final userCredential = await _auth.signInWithCredential(credential);
    // return _mapFirebaseUserToAuthorized(userCredential.user!);
    throw UnimplementedError('Google Sign-In requires google_sign_in package');
  }

  @override
  Future<AuthorizedUser> signInWithFacebook() async {
    // TODO: Implement Facebook Sign-In
    // You'll need to add flutter_facebook_auth package and configure it
    throw UnimplementedError(
      'Facebook Sign-In requires flutter_facebook_auth package',
    );
  }

  @override
  Future<AuthorizedUser> signInWithApple() async {
    // TODO: Implement Apple Sign-In
    // You'll need to add sign_in_with_apple package and configure it
    throw UnimplementedError(
      'Apple Sign-In requires sign_in_with_apple package',
    );
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
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
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
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

  // Helper methods

  /// Maps Firebase User to UserEntity
  UserEntity _mapFirebaseUser(User? user) {
    if (user == null) {
      return const UnauthorizedUser();
    }
    return _mapFirebaseUserToAuthorized(user);
  }

  /// Maps Firebase User to AuthorizedUser
  AuthorizedUser _mapFirebaseUserToAuthorized(User user) {
    return AuthorizedUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
    );
  }

  /// Handles Firebase Auth exceptions and converts them to more readable messages
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
