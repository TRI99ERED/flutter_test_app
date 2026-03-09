import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
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

  Stream<List<String>> watchUserNames() {
    return watchAllUsers().map(
      (users) => users.map((user) => user.name).toList(),
    );
  }

  Future<String> getOtherName(String chatId) {
    if (state.user is! AuthorizedUser) {
      return Future.error('User not authorized');
    }

    final currentUserId = (state.user as AuthorizedUser).id;

    return _firestoreRepository
        .watchChatsForUser(currentUserId)
        .firstWhere((chats) => chats.any((chat) => chat.id == chatId))
        .then((chats) async {
          final chat = chats.firstWhere((chat) => chat.id == chatId);
          final otherUserId = chat.participants.firstWhere(
            (id) => id != currentUserId,
          );

          // Find the user object and return its name
          final allUsers = await watchAllUsers().first;
          final otherUser = allUsers.firstWhere(
            (user) => user.id == otherUserId,
          );
          return otherUser.name;
        });
  }

  Stream<List<Message>> watchMessagesForChat(String chatId) {
    return _firestoreRepository.watchMessagesForChat(chatId: chatId);
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

  Stream<int> watchChatUnreadCount(String chatId) {
    return _firestoreRepository.watchChatUnreadCount(chatId: chatId);
  }

  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) {
    return _firestoreRepository.updateChatUnreadCount(
      chatId: chatId,
      unreadCount: unreadCount,
    );
  }

  Stream<List<AuthorizedUser>> watchFriendsForUser(String userId) {
    return _firestoreRepository.watchFriendsForUser(userId: userId);
  }

  Future<void> sendFriendRequest(
    String currentUserId,
    String friendUserId,
  ) async {
    return _firestoreRepository.sendFriendRequest(
      currentUserId: currentUserId,
      friendUserId: friendUserId,
    );
  }

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
    required String currentUserId,
    required String friendUserId,
  }) async {
    return _firestoreRepository.acceptFriendRequest(
      currentUserId: currentUserId,
      friendUserId: friendUserId,
    );
  }

  Future<void> declineFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) async {
    return _firestoreRepository.declineFriendRequest(
      currentUserId: currentUserId,
      friendUserId: friendUserId,
    );
  }

  Future<void> cancelFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) async {
    return _firestoreRepository.cancelFriendRequest(
      currentUserId: currentUserId,
      friendUserId: friendUserId,
    );
  }

  Future<void> removeFriend({
    required String currentUserId,
    required String friendUserId,
  }) async {
    return _firestoreRepository.removeFriend(
      currentUserId: currentUserId,
      friendUserId: friendUserId,
    );
  }

  Future<void> deleteChat(String chatId) async {
    return _firestoreRepository.deleteChat(chatId);
  }

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
    required String ownerId,
    required String projectName,
    required String projectDescription,
    required List<String> participants,
  }) async {
    return _firestoreRepository.createProjectForUser(
      ownerId,
      projectName,
      projectDescription,
      participants,
    );
  }

  Future<String?> getProjectName(String projectId) async {
    try {
      final projects = await _firestoreRepository
          .watchProjectsForUser((state.user as AuthorizedUser).id)
          .first;

      final project = projects.firstWhere((p) => p.id == projectId);
      return project.name;
    } catch (e) {
      debugPrint('Failed to get project name: $e');
      return null;
    }
  }

  Future<Project?> getProjectWithId(String projectId) async {
    try {
      final projects = await _firestoreRepository
          .watchProjectsForUser((state.user as AuthorizedUser).id)
          .first;

      final project = projects.firstWhere((p) => p.id == projectId);
      return project;
    } catch (e) {
      debugPrint('Failed to get project with id: $e');
      return null;
    }
  }

  Future<AuthorizedUser?> getUserWithId(String userId) async {
    try {
      final users = await _firestoreRepository.watchAllUsers().first;
      final user = users.firstWhere((u) => u.id == userId);
      return user;
    } catch (e) {
      debugPrint('Failed to get user with id: $e');
      return null;
    }
  }

  Future<void> updateProject(Project project) async {
    return _firestoreRepository.updateProject(project);
  }

  Stream<List<AuthorizedUser>> watchProjectParticipants(String projectId) {
    return _firestoreRepository.watchProjectWithId(projectId).asyncExpand((
      project,
    ) {
      final participantIds = project.participants.toSet();
      return _firestoreRepository.watchAllUsers().map((users) {
        return users.where((user) => participantIds.contains(user.id)).toList();
      });
    });
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

  Future<bool> isFriend(String userId, String friendId) async {
    return _firestoreRepository
        .watchFriendsForUser(userId: userId)
        .map((friends) => friends.any((friend) => friend.id == friendId))
        .firstWhere((isFriend) => true, orElse: () => false);
  }

  Future<bool> isUserProjectParticipant(String userId, String projectId) async {
    return _firestoreRepository
        .watchProjectWithId(projectId)
        .map((project) => project.participants.contains(userId))
        .firstWhere((isParticipant) => true, orElse: () => false);
  }

  Future<void> deleteProject(String projectId) async {
    return _firestoreRepository.deleteProject(projectId);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
