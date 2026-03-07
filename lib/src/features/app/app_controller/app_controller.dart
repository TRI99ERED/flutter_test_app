import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/firebase_auth_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  final IFirebaseAuthRepository _authRepository;
  final IFirebaseFirestoreRepository _firestoreRepository;

  AppController()
    : _authRepository = FirebaseAuthRepositoryImpl(),
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
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
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      await _firestoreRepository.createUser(user);
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
  }

  Future<void> sendEmailVerification() async {
    setState(
      AppState.processing(
        message: 'Sending verification code...',
        user: state.user,
      ),
    );
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
  }

  Future<void> login(String email, String password) async {
    setState(AppState.processing(message: 'Signing in...', user: state.user));
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
  }

  Future<void> logout() async {
    setState(AppState.processing(message: 'Signing out...', user: state.user));
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
  }

  Future<void> verifyEmailCode(String code) async {
    setState(
      AppState.processing(message: 'Verifying email code...', user: state.user),
    );
    try {
      await _authRepository.verifyEmailCode(code: code);
      setState(
        AppState.idle(message: 'Email verified successfully', user: state.user),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Email verification failed: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> resendEmailVerification() async {
    setState(
      AppState.processing(
        message: 'Resending verification code...',
        user: state.user,
      ),
    );
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
  }

  Stream<List<Chat>> watchChatsForUser(String userId) {
    return _firestoreRepository.watchChatsForUser(userId);
  }

  Future<String> createOrGetDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) {
    return _firestoreRepository.createOrGetDirectChat(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
    );
  }

  Stream<List<AuthorizedUser>> watchAllUsers() {
    return _firestoreRepository.watchAllUsers();
  }

  Future<String> getOtherName(String chatId) {
    if (state.user is! AuthorizedUser) {
      return Future.error('User not authorized');
    }

    final currentUserId = (state.user as AuthorizedUser).id;

    return _firestoreRepository
        .watchChatsForUser(currentUserId)
        .firstWhere((chats) => chats.any((chat) => chat.id == chatId))
        .then((chats) {
          final chat = chats.firstWhere((chat) => chat.id == chatId);
          final otherUserId = chat.participants.firstWhere(
            (id) => id != currentUserId,
          );
          return chat.participantNames[otherUserId] ?? 'Unknown';
        });
  }

  Stream<List<Message>> watchMessagesForChat(String chatId) {
    return _firestoreRepository.watchMessagesForChat(chatId);
  }

  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) {
    return _firestoreRepository.createMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      body: body,
    );
  }

  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) {
    return _firestoreRepository.updateChatLastMessage(
      chatId: chatId,
      lastMessage: lastMessage,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
