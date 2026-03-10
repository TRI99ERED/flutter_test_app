import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/firebase_auth_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_auth_repository/ifirebase_auth_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/firebase_storage_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/ifirebase_storage_repository.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  final IFirebaseAuthRepository _authRepository;
  final IFirebaseFirestoreRepository _firestoreRepository;
  final IFirebaseStorageRepository _storageRepository;
  Stream<AuthorizedUser>? _userStream;
  StreamSubscription<AuthorizedUser>? _userStreamSubscription;

  AppController()
    : _authRepository = FirebaseAuthRepositoryImpl(),
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
      _storageRepository = FirebaseStorageRepositoryImpl(),
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
    _startUserSync();
  }

  Future<void> _initializeAuthState() async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Initializing auth state...',
            user: state.user,
          ),
        );
        try {
          final user = await _authRepository.getCurrentUser();
          debugPrint('Auth state initialized: $user');
          setState(AppState.idle(message: 'Auth initialized', user: user));
          _startUserSync();
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Failed to initialize auth state: ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        }
      });

  void _startUserSync() {
    if (state.user is! AuthorizedUser) {
      _userStreamSubscription?.cancel();
      return;
    }
    final userId = (state.user as AuthorizedUser).id;
    _userStream = watchUserWithId(userId);
    _userStreamSubscription?.cancel();
    _userStreamSubscription = _userStream!.listen((user) {
      setState(AppState.idle(message: 'User synced from Firebase', user: user));
    });
  }

  Future<void> register(
    String email,
    String password,
    String name,
  ) async => await serialExecutor.synchronized(() async {
    setState(AppState.processing(message: 'Registering...', user: state.user));
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
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
      });

  Future<void> login(String email, String password) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(message: 'Signing in...', user: state.user),
        );
        try {
          final user = await _authRepository.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          setState(AppState.idle(message: 'Sign in successful', user: user));
          _startUserSync();
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
          await _authRepository.resendEmailVerification();
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

  Stream<List<Chat>> watchChatsForUser(String userId) {
    return _firestoreRepository.watchChatsForUser(userId);
  }

  Future<Chat> createChat({
    required List<String> participants,
    required String chatName,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Creating chat "$chatName"...',
        user: state.user,
      ),
    );
    try {
      final chat = await _firestoreRepository.createChat(
        participants: participants,
        chatName: chatName,
        groupOwnerId: participants.length > 2
            ? (state.user as AuthorizedUser).id
            : '',
      );
      setState(
        AppState.idle(
          message: 'Chat "$chatName" created successfully, id: "${chat.id}"',
          user: state.user,
        ),
      );
      return chat;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message: 'Failed to create chat "$chatName": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  });

  Stream<List<AuthorizedUser>> watchAllUsers() {
    return _firestoreRepository.watchAllUsers();
  }

  Stream<List<Message>> watchMessagesForChat(String chatId) {
    return _firestoreRepository.watchMessagesForChat(chatId: chatId);
  }

  Future<Message> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Sending message "$body" in chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      final message = await _firestoreRepository.createMessage(
        chatId: chatId,
        senderId: senderId,
        body: body,
      );
      setState(
        AppState.idle(
          message:
              'Message "$body" sent successfully in chat "$chatId", id: "${message.id}"',
          user: state.user,
        ),
      );
      return message;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to send message "$body" in chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  });

  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating last message for chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateChatLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
      );
      setState(
        AppState.idle(
          message: 'Last message for chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update last message for chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  });

  Stream<int> watchChatUnreadCount(String chatId) {
    return _firestoreRepository.watchChatUnreadCount(chatId: chatId);
  }

  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Updating unread count for chat "$chatId"...',
        user: state.user,
      ),
    );
    try {
      await _firestoreRepository.updateChatUnreadCount(
        chatId: chatId,
        unreadCount: unreadCount,
      );
      setState(
        AppState.idle(
          message: 'Unread count for chat "$chatId" updated successfully',
          user: state.user,
        ),
      );
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to update unread count for chat "$chatId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  });

  Stream<List<AuthorizedUser>> watchFriendsForUser(String userId) {
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
      rethrow;
    }
  });

  Stream<List<AuthorizedUser>> watchFriendIncomingRequestsForUser(
    String userId,
  ) {
    return _firestoreRepository.watchFriendIncomingRequestsForUser(
      userId: userId,
    );
  }

  Stream<List<AuthorizedUser>> watchFriendOutgoingRequestsForUser(
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  });

  Future<void> deleteChat(String chatId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Deleting chat "$chatId"...',
            user: state.user,
          ),
        );
        try {
          await _firestoreRepository.deleteChat(chatId);
          setState(
            AppState.idle(
              message: 'Chat "$chatId" deleted successfully',
              user: state.user,
            ),
          );
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message: 'Failed to delete chat "$chatId": ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          rethrow;
        }
      });

  Stream<List<AuthorizedUser>> watchAllUsersExcludingFriends(String userId) {
    return _firestoreRepository.watchAllUsers().asyncMap((users) async {
      final friends = await _firestoreRepository
          .watchFriendsForUser(userId: userId)
          .first;

      final friendIds = friends.map((friend) => friend.id).toSet();

      return users
          .where((user) => user.id != userId && !friendIds.contains(user.id))
          .toList();
    });
  }

  Stream<List<Project>> watchToDoProjectsForUser(String userId) {
    return _firestoreRepository.watchProjectsForUser(userId).map((projects) {
      return projects
          .where((project) => project.status == ProjectStatus.todo)
          .toList();
    });
  }

  Stream<List<Project>> watchInProgressProjectsForUser(String userId) {
    return _firestoreRepository.watchProjectsForUser(userId).map((projects) {
      return projects
          .where((project) => project.status == ProjectStatus.inProgress)
          .toList();
    });
  }

  Stream<List<Project>> watchFinishedProjectsForUser(String id) {
    return _firestoreRepository.watchProjectsForUser(id).map((projects) {
      return projects
          .where((project) => project.status == ProjectStatus.finished)
          .toList();
    });
  }

  Future<Project> createProjectForUser({
    required String projectName,
    required String projectDescription,
    required List<String> participants,
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
      rethrow;
    }
  });

  Future<Project> getProjectWithId(
    String projectId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      AppState.processing(
        message: 'Loading project with id "$projectId"...',
        user: state.user,
      ),
    );
    try {
      final projects = await _firestoreRepository
          .watchProjectsForUser(
            state.user is AuthorizedUser
                ? (state.user as AuthorizedUser).id
                : '',
          )
          .first;

      final project = projects.firstWhere((p) => p.id == projectId);
      setState(
        AppState.idle(
          message: 'Project with id "$projectId" loaded successfully',
          user: state.user,
        ),
      );
      return project;
    } catch (error, stackTrace) {
      setState(
        AppState.failed(
          message:
              'Failed to get project with id "$projectId": ${error.toString()}',
          user: state.user,
          error: error,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  });

  Future<AuthorizedUser> getUserWithId(String userId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          AppState.processing(
            message: 'Loading user with id "$userId"...',
            user: state.user,
          ),
        );
        try {
          final users = await _firestoreRepository.watchAllUsers().first;
          final user = users.firstWhere((u) => u.id == userId);
          setState(
            AppState.idle(
              message: 'User with id "$userId" loaded successfully',
              user: state.user,
            ),
          );
          return user;
        } catch (error, stackTrace) {
          setState(
            AppState.failed(
              message:
                  'Failed to get user with id "$userId": ${error.toString()}',
              user: state.user,
              error: error,
              stackTrace: stackTrace,
            ),
          );
          rethrow;
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
      rethrow;
    }
  });

  Stream<List<AuthorizedUser>> watchProjectParticipants(String projectId) {
    return Rx.combineLatest2(
      _firestoreRepository.watchProjectWithId(projectId),
      _firestoreRepository.watchAllUsers(),
      (Project project, List<AuthorizedUser> users) {
        final participantIds = project.participants.toSet();
        return users.where((user) => participantIds.contains(user.id)).toList();
      },
    );
  }

  Stream<Project> watchProjectWithId(String projectId) {
    return _firestoreRepository.watchProjectWithId(projectId);
  }

  Stream<List<AuthorizedUser>> watchAllUsersExcludingProjectParticipants(
    String userId,
    String projectId,
  ) {
    return _firestoreRepository.watchAllUsers().asyncMap((users) async {
      final project = await _firestoreRepository
          .watchProjectWithId(projectId)
          .first;

      final participantIds = project.participants.toSet();

      return users
          .where((u) => u.id != userId && !participantIds.contains(u.id))
          .toList();
    });
  }

  Stream<AuthorizedUser> watchUserWithId(String memberId) {
    return _firestoreRepository.watchAllUsers().map((users) {
      return users.firstWhere((u) => u.id == memberId);
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
          .map((friends) => friends.any((friend) => friend.id == friendId))
          .firstWhere((isFriend) => true, orElse: () => false);
      setState(
        AppState.idle(
          message: 'Friend check for user "$friendId" completed: $isFriend',
          user: state.user,
        ),
      );
      return isFriend;
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
      rethrow;
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
          .map((project) => project.participants.contains(userId))
          .firstWhere((isParticipant) => true, orElse: () => false);
      setState(
        AppState.idle(
          message:
              'Participant check for user "$userId" in project "$projectId" completed: $isParticipant',
          user: state.user,
        ),
      );
      return isParticipant;
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
      rethrow;
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
          rethrow;
        }
      });

  Stream<Chat> watchChatWithId(String chatId) {
    return _firestoreRepository.watchChatWithId(chatId);
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
      XFile? imageFile;
      if (!kIsWeb) {
        imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        imageFile = await ImagePickerPlugin().getImageFromSource(
          source: ImageSource.gallery,
        );
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
      _startUserSync();
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
      rethrow;
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
      rethrow;
    }
  });

  @override
  void dispose() {
    super.dispose();
    _userStreamSubscription?.cancel();
  }
}
