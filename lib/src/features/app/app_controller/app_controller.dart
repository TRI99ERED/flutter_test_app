import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/notification_settings.dart';
import 'package:test_app/src/features/app/data/models/project_feedback_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/firebase_auth_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_functions_repository/firebase_functions_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_functions_repository/ifirebase_functions_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_messaging_repository/firebase_messaging_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_messaging_repository/ifirebase_messaging_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/firebase_storage_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/ifirebase_storage_repository.dart';
import 'package:test_app/src/features/app/data/repositories/shared_preferences/ishared_preferences_repository.dart';
import 'package:test_app/src/features/app/data/repositories/shared_preferences/shared_preferences_repository_impl.dart';
import 'package:test_app/src/services/notification_service.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  final IFirebaseAuthRepository _authRepository;
  final IFirebaseFirestoreRepository _firestoreRepository;
  final IFirebaseStorageRepository _storageRepository;
  final IFirebaseFunctionsRepository _functionsRepository;
  final ISharedPreferencesRepository _sharedPreferencesRepository;
  final IFirebaseMessagingRepository _messagingRepository;
  Stream<UserEntity>? _userStream;
  StreamSubscription<UserEntity>? _userStreamSubscription;
  StreamSubscription<String>? _fcmTokenRefreshSubscription;

  /// `true` after the first auth state callback has been received.
  bool isInitialized = false;

  /// Notifies only when the authorization status changes.
  /// Use this as `refreshListenable` for navigation instead of the
  /// whole controller, to avoid unnecessary guard evaluations.
  final authNotifier = ValueNotifier<bool>(false);

  void _updateAuthNotifier() {
    final isAuthorized = state.isAuthorized;
    if (authNotifier.value != isAuthorized) {
      authNotifier.value = isAuthorized;
    }
  }

  AppController()
    : _authRepository = FirebaseAuthRepositoryImpl(),
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
      _storageRepository = FirebaseStorageRepositoryImpl(),
      _functionsRepository = FirebaseFunctionsRepositoryImpl(),
      _sharedPreferencesRepository = SharedPreferencesRepositoryImpl(),
      _messagingRepository = FirebaseMessagingRepositoryImpl(),
      super(
        state: const AppState.idle(
          message: 'initialized',
          user: UnauthorizedUser(),
        ),
        name: 'AppController',
      ) {
    _listenToAuthState();
    _listentoFcmTokenRefresh();
  }

  void _listentoFcmTokenRefresh() {
    _fcmTokenRefreshSubscription?.cancel();
    _fcmTokenRefreshSubscription = _messagingRepository.onTokenRefresh().listen(
      (newToken) {
        if (state.user is AuthorizedUser) {
          final user = state.user as AuthorizedUser;
          final updatedUser =
              user.copyWith(fcmToken: newToken) as AuthorizedUser;
          _firestoreRepository.updateUser(updatedUser);
          setState(
            AppState.idle(message: 'FCM token refreshed', user: updatedUser),
          );
        }
      },
      onError: (error, stackTrace) {
        setState(
          AppState.failed(
            message:
                'Failed to listen to FCM token refresh: ${error.toString()}',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
    );
  }

  void _listenToAuthState() {
    _userStreamSubscription?.cancel();
    _userStream = _authRepository.authStateChanges;
    _userStreamSubscription = _userStream?.listen(
      (user) {
        final wasInitialized = isInitialized;
        isInitialized = true;
        setState(AppState.idle(message: 'Auth state changed', user: user));
        _updateAuthNotifier();
        if (!wasInitialized && isInitialized) {
          authNotifier.notifyListeners();
        }
        if (user is AuthorizedUser) {
          loadNotificationsSettings();
        }
      },
      onError: (error, stackTrace) {
        final wasInitialized = isInitialized;
        isInitialized = true;
        setState(
          AppState.failed(
            message: 'Auth state listen failed: ${error.toString()}',
            user: state.user,
            error: error,
            stackTrace: stackTrace,
          ),
        );
        _updateAuthNotifier();
        if (!wasInitialized && isInitialized) {
          authNotifier.notifyListeners();
        }
      },
    );
  }

  Future<void> register(
    String email,
    String password,
    String name,
  ) async => await serialExecutor.synchronized(() async {
    setState(AppState.processing(message: 'Registering...', user: state.user));
    try {
      var user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      final fcmToken = await _messagingRepository.getToken();
      user = user.copyWith(fcmToken: fcmToken) as AuthorizedUser;
      await _firestoreRepository.createUser(user: user);
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

  Future<void> sendEmailVerification() async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Sending verification code...',
            user: state.user,
          ),
        );
        try {
          await _functionsRepository.sendEmailVerification();
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

  Future<void> login(
    String email,
    String password,
  ) async => await serialExecutor.synchronized(() async {
    setState(AppState.processing(message: 'Signing in...', user: state.user));
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fcmToken = await _messagingRepository.getToken();
      final updatedUser = user.copyWith(fcmToken: fcmToken) as AuthorizedUser;
      await _firestoreRepository.updateUser(updatedUser);
      setState(AppState.idle(message: 'Sign in successful', user: updatedUser));
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

  Future<void> logout() async => await serialExecutor.synchronized(() async {
    setState(AppState.processing(message: 'Signing out...', user: state.user));
    try {
      if (state.user is AuthorizedUser) {
        final user = state.user as AuthorizedUser;
        final updatedUser = user.copyWith(fcmToken: '') as AuthorizedUser;
        await _firestoreRepository.updateUser(updatedUser);
      }
      await _authRepository.signOut();
      setState(
        AppState.idle(
          message: 'Sign out successful',
          user: const UnauthorizedUser(),
        ),
      );
      _userStreamSubscription?.cancel();
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

  Future<void> verifyEmailCode(
    String code,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(message: 'Verifying email code...', user: state.user),
    );
    try {
      await _functionsRepository.verifyEmailCode(code: code);
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
  });

  Future<void> resendEmailVerification() async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Resending verification code...',
            user: state.user,
          ),
        );
        try {
          await _functionsRepository.resendEmailVerification();
          setState(
            AppState.idle(
              message: 'Verification code resent',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to resend verification code: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        }
      });

  Stream<List<DirectChat>?> watchDirectChatsForUser(String userId) {
    return _firestoreRepository.watchDirectChatsForUser(userId);
  }

  Stream<List<GroupChat>?> watchGroupChatsForUser(String userId) {
    return _firestoreRepository.watchGroupChatsForUser(userId);
  }

  Future<DirectChat> createDirectChat({
    required List<String> participants,
    required String chatName,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Creating direct chat "$chatName"...',
        user: state.user,
      ),
    );
    try {
      final chat = await _firestoreRepository.createDirectChat(
        participants: participants,
        chatName: chatName,
      );
      setState(
        AppState.idle(
          message:
              'Direct chat "$chatName" created successfully, id: "${chat.id}"',
          user: state.user,
        ),
      );
      return chat;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to create direct chat "$chatName": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<GroupChat> createGroupChat({
    required String chatName,
    required List<String> participants,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Creating group chat "$chatName"...',
        user: state.user,
      ),
    );
    try {
      final chat = await _firestoreRepository.createGroupChat(
        chatName: chatName,
        participants: participants,
        ownerId: (state.user as AuthorizedUser).id,
      );
      setState(
        AppState.idle(
          message:
              'Group chat "$chatName" created successfully, id: "${chat.id}"',
          user: state.user,
        ),
      );
      return chat;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to create group chat "$chatName": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchAllUsers() {
    return _firestoreRepository.watchAllUsers();
  }

  Stream<List<Message>?> watchMessagesForDirectChat(String chatId) {
    return _firestoreRepository.watchMessagesForDirectChat(chatId: chatId);
  }

  Stream<List<Message>?> watchMessagesForGroupChat(String chatId) {
    return _firestoreRepository.watchMessagesForGroupChat(chatId: chatId);
  }

  Future<Message> createDirectChatMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Sending message "$body" in direct chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final message = await _firestoreRepository.createDirectChatMessage(
        chatId: chatId,
        senderId: senderId,
        body: body,
      );
      setState(
        AppState.idle(
          message:
              'Message "$body" sent successfully in direct chat "$chatId", id: "${message.id}"',
          user: state.user,
        ),
      );
      return message;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to send message "$body" in direct chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<Message> createGroupChatMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Sending message "$body" in group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final message = await _firestoreRepository.createGroupChatMessage(
        chatId: chatId,
        senderId: senderId,
        body: body,
      );
      setState(
        AppState.idle(
          message:
              'Message "$body" sent successfully in group chat "$chatId", id: "${message.id}"',
          user: state.user,
        ),
      );
      return message;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to send message "$body" in group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateDirectChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating last message for direct chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateDirectChatLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
      );
      setState(
        AppState.idle(
          message:
              'Last message for direct chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update last message for direct chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateGroupChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating last message for group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateGroupChatLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
      );
      setState(
        AppState.idle(
          message: 'Last message for group chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update last message for group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<int?> watchDirectChatUnreadCount(String chatId) {
    return _firestoreRepository.watchDirectChatUnreadCount(chatId: chatId);
  }

  Stream<Map<String, int>?> watchGroupChatUnreadCounts(String chatId) {
    return _firestoreRepository.watchGroupChatUnreadCounts(chatId: chatId);
  }

  Future<void> updateDirectChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating unread count for direct chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateDirectChatUnreadCount(
        chatId: chatId,
        unreadCount: unreadCount,
      );
      setState(
        AppState.idle(
          message:
              'Unread count for direct chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update unread count for direct chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateGroupChatUnreadCounts({
    required String chatId,
    required Map<String, int> unreadCounts,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating unread counts for group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateGroupChatUnreadCounts(
        chatId: chatId,
        unreadCounts: unreadCounts,
      );
      setState(
        AppState.idle(
          message:
              'Unread counts for group chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update unread counts for group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchFriendsForUser(String userId) {
    return _firestoreRepository.watchFriendsForUser(userId: userId);
  }

  Future<void> sendFriendRequest(
    String currentUserId,
    String friendUserId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Sending friend request to "$friendUserId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.sendFriendRequest(
        currentUserId: currentUserId,
        friendUserId: friendUserId,
      );
      setState(
        AppState.idle(
          message: 'Friend request sent to "$friendUserId" successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to send friend request to "$friendUserId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchFriendIncomingRequestsForUser(
    String userId,
  ) {
    return _firestoreRepository.watchFriendIncomingRequestsForUser(
      userId: userId,
    );
  }

  Stream<List<AuthorizedUser>?> watchFriendOutgoingRequestsForUser(
    String userId,
  ) {
    return _firestoreRepository.watchFriendOutgoingRequestsForUser(
      userId: userId,
    );
  }

  Future<void> acceptFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Accepting friend request from "$friendUserId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.acceptFriendRequest(
        currentUserId: state.user is AuthorizedUser
            ? (state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        AppState.idle(
          message: 'Friend request from "$friendUserId" accepted successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to accept friend request from "$friendUserId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> declineFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Declining friend request from "$friendUserId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.declineFriendRequest(
        currentUserId: state.user is AuthorizedUser
            ? (state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        AppState.idle(
          message: 'Friend request from "$friendUserId" declined successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to decline friend request from "$friendUserId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> cancelFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Cancelling friend request to "$friendUserId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.cancelFriendRequest(
        currentUserId: state.user is AuthorizedUser
            ? (state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        AppState.idle(
          message: 'Friend request to "$friendUserId" cancelled successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to cancel friend request to "$friendUserId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> removeFriend({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Removing friend "$friendUserId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.removeFriend(
        currentUserId: state.user is AuthorizedUser
            ? (state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        AppState.idle(
          message: 'Friend "$friendUserId" removed successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to remove friend "$friendUserId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> deleteDirectChat(String chatId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Deleting direct chat "$chatId"...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.deleteDirectChat(chatId);
          setState(
            AppState.idle(
              message: 'Direct chat "$chatId" deleted successfully',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to delete direct chat "$chatId": ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> deleteGroupChat(String chatId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Deleting group chat "$chatId"...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.deleteGroupChat(chatId);
          final projects = await _firestoreRepository
              .watchProjectsForUser(
                (state.user as AuthorizedUser).id,
                'lastUpdated',
                true,
              )
              .first;
          final associatedProject = projects?.firstWhere(
            (p) => p.groupChatId == chatId,
            orElse: () => Project(
              id: '',
              name: '',
              description: '',
              ownerId: '',
              participants: [],
              status: ProjectStatus.todo,
              createdAt: DateTime.now(),
              lastUpdated: DateTime.now(),
              deadline: DateTime.now(),
            ),
          );
          if (associatedProject != null && associatedProject.id.isNotEmpty) {
            await updateProject(associatedProject.copyWith(groupChatId: ''));
          }
          setState(
            AppState.idle(
              message: 'Group chat "$chatId" deleted successfully',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to delete group chat "$chatId": ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Stream<List<Project>?> watchToDoProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.todo)
              .toList();
        });
  }

  Stream<List<Project>?> watchInProgressProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.inProgress)
              .toList();
        });
  }

  Stream<List<Project>?> watchFinishedProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.finished)
              .toList();
        });
  }

  Future<Project> createProjectForUser({
    required String projectName,
    required String projectDescription,
    required List<String> participants,
    required DateTime deadline,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Creating project "$projectName"...',
        user: state.user,
      ),
    );
    try {
      final project = await _firestoreRepository.createProjectForUser(
        state.user is AuthorizedUser ? (state.user as AuthorizedUser).id : '',
        projectName,
        projectDescription,
        participants,
        deadline,
      );
      setState(
        AppState.idle(
          message:
              'Project "$projectName" created successfully, id: "${project.id}"',
          user: state.user,
        ),
      );
      return project;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to create project "$projectName": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateProject(
    Project project,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating project "${project.name}"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateProject(project);
      setState(
        AppState.idle(
          message: 'Project "${project.name}" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update project "${project.name}": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchProjectParticipants(String projectId) {
    return Rx.combineLatest2(
      _firestoreRepository.watchProjectWithId(projectId),
      _firestoreRepository.watchAllUsers(),
      (Project? project, List<AuthorizedUser>? users) {
        final participantIds = project?.participants.toSet() ?? {};
        return users
            ?.where((user) => participantIds.contains(user.id))
            .toList();
      },
    );
  }

  Stream<Project?> watchProjectWithId(String projectId) {
    return _firestoreRepository.watchProjectWithId(projectId);
  }

  Stream<AuthorizedUser?> watchUserWithId(String memberId) {
    return _firestoreRepository.watchAllUsers().map((users) {
      return users?.firstWhere((u) => u.id == memberId);
    });
  }

  Future<bool> isFriend(
    String userId,
    String friendId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Checking if user "$friendId" is a friend...',
        user: state.user,
      ),
    );
    try {
      final isFriend = await _firestoreRepository
          .watchFriendsForUser(userId: userId)
          .map((friends) => friends?.any((friend) => friend.id == friendId))
          .firstWhere((isFriend) => true, orElse: () => false);
      setState(
        AppState.idle(
          message: 'Friend check for user "$friendId" completed: $isFriend',
          user: state.user,
        ),
      );
      return isFriend ?? false;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to check if user "$friendId" is a friend: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<bool> isUserProjectParticipant(
    String userId,
    String projectId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message:
            'Checking if user "$userId" is a participant of project "$projectId"...',
        user: state.user,
      ),
    );
    try {
      final isParticipant = await _firestoreRepository
          .watchProjectWithId(projectId)
          .map((project) => project?.participants.contains(userId))
          .firstWhere((isParticipant) => true, orElse: () => false);
      setState(
        AppState.idle(
          message:
              'Participant check for user "$userId" in project "$projectId" completed: $isParticipant',
          user: state.user,
        ),
      );
      return isParticipant ?? false;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to check if user "$userId" is a participant of project "$projectId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> deleteProject(String projectId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Deleting project "$projectId"...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.deleteProject(projectId);
          setState(
            AppState.idle(
              message: 'Project "$projectId" deleted successfully.',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to delete project "$projectId": ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Stream<DirectChat?> watchDirectChatWithId(String chatId) {
    return _firestoreRepository.watchDirectChatWithId(chatId);
  }

  Stream<GroupChat?> watchGroupChatWithId(String chatId) {
    return _firestoreRepository.watchGroupChatWithId(chatId);
  }

  Future<void>
  uploadUserAvatar() async => await serialExecutor.synchronized(() async {
    final userId = state.user is AuthorizedUser
        ? (state.user as AuthorizedUser).id
        : '';
    setState(
      AppState.processing(
        message: 'Uploading avatar for user "$userId"...',
        user: state.user,
      ),
    );
    try {
      File? imageFile;
      if (!kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.isNotEmpty) {
          imageFile = File(result.files.single.path!);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.isNotEmpty) {
          imageFile = File(result.files.single.path!);
        }
      }
      if (imageFile == null) {
        setState(
          AppState.idle(
            message: 'Avatar upload cancelled by user "$userId".',
            user: state.user,
          ),
        );
        return;
      }
      final url = await _storageRepository.uploadUserAvatar(
        userId: userId,
        file: imageFile,
      );
      await _firestoreRepository.updateUserAvatarUrl(userId: userId, url: url);
      setState(
        AppState.idle(
          message: 'Avatar uploaded successfully for user "$userId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to upload avatar for user "$userId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void>
  deleteUserAvatar() async => await serialExecutor.synchronized(() async {
    final userId = state.user is AuthorizedUser
        ? (state.user as AuthorizedUser).id
        : '';
    setState(
      AppState.processing(
        message: 'Deleting avatar for user "$userId"...',
        user: state.user,
      ),
    );
    try {
      await _storageRepository.deleteUserAvatar(userId: userId);
      setState(
        AppState.idle(
          message: 'Avatar deleted successfully for user "$userId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to delete avatar for user "$userId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> uploadGroupChatAvatar(
    String chatId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Uploading avatar for group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final imageFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (imageFile == null) {
        setState(
          AppState.idle(
            message: 'Group chat avatar upload cancelled for chat "$chatId".',
            user: state.user,
          ),
        );
        return;
      }
      final url = await _functionsRepository.uploadGroupAvatar(
        chatId: chatId,
        filename: imageFile.files.first.name,
        avatarBytes: imageFile.files.first.bytes!,
      );
      await _firestoreRepository.updateGroupChatAvatarUrl(
        chatId: chatId,
        url: url,
      );
      setState(
        AppState.idle(
          message: 'Avatar uploaded successfully for group chat "$chatId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to upload avatar for group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> deleteGroupChatAvatar(
    String chatId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Deleting avatar for group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final currentAvatarUrl = await _firestoreRepository
          .watchGroupChatWithId(chatId)
          .map((chat) => chat?.avatarUrl)
          .firstWhere((url) => url != null, orElse: () => null);
      if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
        setState(
          AppState.idle(
            message: 'No avatar to delete for group chat "$chatId".',
            user: state.user,
          ),
        );
        return;
      }
      await _functionsRepository.deleteGroupAvatar(
        chatId: chatId,
        filename: currentAvatarUrl.split('/').last,
      );
      setState(
        AppState.idle(
          message: 'Avatar deleted successfully for group chat "$chatId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to delete avatar for group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<Chat>?> watchAllChatsForUser(String userId) {
    return _firestoreRepository.watchAllChatsForUser(userId);
  }

  Future<void> updateUserCurrentDirectChatId({
    required String userId,
    String currentDirectChatId = '',
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating current direct chat for user "$userId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateUserCurrentDirectChatId(
        userId: userId,
        currentDirectChatId: currentDirectChatId,
      );
      setState(
        AppState.idle(
          message:
              'Current direct chat updated successfully for user "$userId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update current direct chat for user "$userId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateUserCurrentGroupChatId({
    required String userId,
    String currentGroupChatId = '',
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating current group chat for user "$userId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateUserCurrentGroupChatId(
        userId: userId,
        currentGroupChatId: currentGroupChatId,
      );
      setState(
        AppState.idle(
          message:
              'Current group chat updated successfully for user "$userId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update current group chat for user "$userId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<String?> watchUserCurrentDirectChatId(String userId) {
    return watchUserWithId(userId).map((user) => user?.currentDirectChatId);
  }

  Stream<String?> watchUserCurrentGroupChatId(String userId) {
    return watchUserWithId(userId).map((user) => user?.currentGroupChatId);
  }

  Future<void> updateGroupChat(
    GroupChat chat,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating group chat "${chat.id}"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateGroupChat(chat);
      setState(
        AppState.idle(
          message: 'Group chat "${chat.id}" updated successfully.',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update group chat "${chat.id}": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<String> watchGroupChatAvatarUrl(String chatId) {
    return _firestoreRepository
        .watchGroupChatWithId(chatId)
        .map((chat) => chat?.avatarUrl ?? '');
  }

  Future<void> updateUser(
    AuthorizedUser user,
  ) async => await serialExecutor.synchronized(() async {
    try {
      if (state.user is! AuthorizedUser) {
        setState(
          AppState.failed(
            message: 'Cannot update user: No authorized user in state.',
            user: state.user,
          ),
        );
        return;
      }
      setState(
        AppState.processing(
          message: 'Updating user "${user.id}"...',
          user: state.user,
        ),
      );
      final fcmToken = await _messagingRepository.getToken();
      final updatedUser = user.copyWith(fcmToken: fcmToken) as AuthorizedUser;
      await _firestoreRepository.updateUser(updatedUser);
      setState(
        AppState.idle(
          message: 'User "${user.id}" updated successfully.',
          user: updatedUser,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to update user "${user.id}": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> sendPasswordResetEmail(
    String email,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Sending password reset email to "$email"...',
        user: state.user,
      ),
    );
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      setState(
        AppState.idle(
          message: 'Password reset email sent successfully to "$email".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to send password reset email to "$email": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<ProjectFeedback> submitProjectFeedback({
    required String projectId,
    required String userId,
    required int starRating,
    required Set<String> likes,
    required Set<String> dislikes,
    required String feedback,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Submitting feedback for project "$projectId"...',
        user: state.user,
      ),
    );
    try {
      final projectFeedback = await _firestoreRepository.submitProjectFeedback(
        projectId: projectId,
        userId: userId,
        starRating: starRating,
        likes: likes,
        dislikes: dislikes,
        feedback: feedback,
      );
      setState(
        AppState.idle(
          message:
              'Feedback submitted successfully for project "$projectId", id: "${projectFeedback.feedbackId}"',
          user: state.user,
        ),
      );
      return projectFeedback;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to submit feedback for project "$projectId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> signInWithGoogle({void Function()? onNewUser}) async {
    setState(
      AppState.processing(
        message: 'Signing in with Google...',
        user: state.user,
      ),
    );
    try {
      final user = await _authRepository.signInWithGoogle();
      final fcmToken = await _messagingRepository.getToken();
      final updatedUser = user?.copyWith(fcmToken: fcmToken) as AuthorizedUser?;
      if (updatedUser == null) {
        setState(
          AppState.idle(
            message: 'Google sign-in was cancelled.',
            user: state.user,
          ),
        );
        return;
      }
      final userExists = await _firestoreRepository.doesUserExist(
        updatedUser.id,
      );
      if (userExists) {
        final existingUser = await _firestoreRepository
            .watchAllUsers()
            .map((users) => users?.firstWhere((u) => u.id == updatedUser.id))
            .firstWhere((u) => u != null, orElse: () => null);

        setState(
          AppState.idle(
            message: 'Signed in with Google successfully.',
            user: existingUser ?? const UnauthorizedUser(),
          ),
        );
        return;
      }
      await _firestoreRepository.createUser(user: updatedUser);
      onNewUser?.call();
      setState(
        AppState.idle(
          message: 'Signed in with Google successfully.',
          user: updatedUser,
        ),
      );
    } on GoogleSignInCanceledException catch (_) {
      setState(
        AppState.idle(
          message: 'Google sign-in was canceled.',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to sign in with Google: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  }

  Future<bool> doesUserExist(
    String id,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Checking if user with id "$id" exists...',
        user: state.user,
      ),
    );
    try {
      final exists = await _firestoreRepository.doesUserExist(id);
      setState(
        AppState.idle(
          message: 'User existence check for id "$id" completed: $exists',
          user: state.user,
        ),
      );
      return exists;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to check if user with id "$id" exists: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> setHasSeenOnboarding(
    bool hasSeen,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating onboarding status...',
        user: state.user,
      ),
    );
    try {
      await _sharedPreferencesRepository.setBool('hasSeenOnboarding', hasSeen);
      setState(
        AppState.idle(
          message: 'Onboarding status updated successfully.',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to update onboarding status: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<bool> hasSeenOnboarding() async {
    setState(
      AppState.processing(
        message: 'Retrieving onboarding status...',
        user: state.user,
      ),
    );
    try {
      final hasSeen =
          await _sharedPreferencesRepository.getBool('hasSeenOnboarding') ??
          false;
      setState(
        AppState.idle(
          message: 'Onboarding status retrieved successfully: $hasSeen',
          user: state.user,
        ),
      );
      return hasSeen;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to retrieve onboarding status: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  }

  Future<void> saveMessage(SavedMessage message) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(message: 'Saving message...', user: state.user),
        );
        try {
          await _firestoreRepository.saveMessage(
            (state.user as AuthorizedUser).id,
            message,
          );
          setState(
            AppState.idle(
              message: 'Message saved successfully, id: "${message.id}"',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Failed to save message: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Stream<List<SavedMessage>?> watchSavedMessages() {
    return _firestoreRepository.watchSavedMessages(
      (state.user as AuthorizedUser).id,
    );
  }

  Future<void> createSavedMessage(String body) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Creating saved message...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.createSavedMessage(
            (state.user as AuthorizedUser).id,
            body,
          );
          setState(
            AppState.idle(
              message: 'Saved message created successfully.',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Failed to create saved message: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> deleteSavedMessage(String messageId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Deleting saved message...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.deleteSavedMessage(
            (state.user as AuthorizedUser).id,
            messageId,
          );
          setState(
            AppState.idle(
              message: 'Saved message deleted successfully.',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Failed to delete saved message: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> saveNotificationsSettings(NotificationSettings settings) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Updating notification settings...',
            user: state.user,
          ),
        );
        try {
          late final AuthorizedUser updatedUser;
          if (!settings.pushNotificationsEnabled) {
            await _messagingRepository.deleteToken();
            updatedUser =
                (state.user as AuthorizedUser).copyWith(
                      fcmToken: '',
                      notificationSettings: settings,
                    )
                    as AuthorizedUser;
          } else {
            final token = await _messagingRepository.getToken();
            updatedUser =
                (state.user as AuthorizedUser).copyWith(
                      fcmToken:
                          token ?? (state.user as AuthorizedUser).fcmToken,
                      notificationSettings: settings,
                    )
                    as AuthorizedUser;
          }
          await _firestoreRepository.updateUser(updatedUser);
          NotificationService.updateSettings(settings);
          setState(
            AppState.idle(
              message: 'Notification settings updated successfully.',
              user: updatedUser,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to update notification settings: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<NotificationSettings> loadNotificationsSettings() async {
    setState(
      AppState.processing(
        message: 'Retrieving notification settings...',
        user: state.user,
      ),
    );
    try {
      final settings =
          await watchUserWithId((state.user as AuthorizedUser).id)
              .map((user) => user?.notificationSettings)
              .firstWhere((settings) => settings != null, orElse: () => null) ??
          const NotificationSettings(
            pushNotificationsEnabled: true,
            messageNotificationsEnabled: true,
            friendRequestNotificationsEnabled: true,
            projectInviteNotificationsEnabled: true,
          );

      late final AuthorizedUser updatedUser;
      if (!settings.pushNotificationsEnabled) {
        await _messagingRepository.deleteToken();
        updatedUser =
            (state.user as AuthorizedUser).copyWith(
                  fcmToken: '',
                  notificationSettings: settings,
                )
                as AuthorizedUser;
      } else {
        final token = await _messagingRepository.getToken();
        if (token != null) {
          updatedUser =
              (state.user as AuthorizedUser).copyWith(
                    fcmToken: token,
                    notificationSettings: settings,
                  )
                  as AuthorizedUser;
        }
      }
      await _firestoreRepository.updateUser(updatedUser);
      NotificationService.updateSettings(settings);
      setState(
        AppState.idle(
          message: 'Notification settings retrieved successfully.',
          user: updatedUser,
        ),
      );
      return settings;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to retrieve notification settings: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  }

  Future<void> updateGroupChatCurrentUserUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message:
            'Updating this user\'s unread count for group chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final groupChatUnreadCounts = await watchGroupChatWithId(
        chatId,
      ).map((chat) => chat?.unreadCounts ?? {}).first;
      final updatedUnreadCounts = Map<String, int>.from(groupChatUnreadCounts)
        ..[(state.user as AuthorizedUser).id] = unreadCount;
      await _firestoreRepository.updateGroupChatUnreadCounts(
        chatId: chatId,
        unreadCounts: updatedUnreadCounts,
      );
      setState(
        AppState.idle(
          message:
              'This user\'s unread count updated successfully for group chat "$chatId".',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update this user\'s unread count for group chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateCurrentRoute(String location) async {
    try {
      await _sharedPreferencesRepository.setString('currentRoute', location);
    } catch (_) {}
  }

  Future<String?> loadCurrentRoute() async {
    try {
      return await _sharedPreferencesRepository.getString('currentRoute');
    } catch (_) {
      return null;
    }
  }

  Future<void> copyTextToClipboard(String body) async {
    setState(
      AppState.processing(
        message: 'Copying text to clipboard...',
        user: state.user,
      ),
    );
    try {
      await Clipboard.setData(ClipboardData(text: body));
      setState(
        AppState.idle(
          message: 'Text copied to clipboard successfully.',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to copy text to clipboard: ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    authNotifier.dispose();
    _userStreamSubscription?.cancel();
    _fcmTokenRefreshSubscription?.cancel();
    super.dispose();
  }
}
