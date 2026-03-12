import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';

abstract interface class IFirebaseFirestoreRepository {
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> cancelFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<DirectChat> createDirectChat({
    required List<String> participants,
    required String chatName,
  });

  Future<Message> createDirectChatMessage({
    required String chatId,
    required String senderId,
    required String body,
  });

  Future<GroupChat> createGroupChat({
    required List<String> participants,
    required String chatName,
    required String ownerId,
  });

  Future<Message> createGroupChatMessage({
    required String chatId,
    required String senderId,
    required String body,
  });

  Future<Project> createProjectForUser(
    String ownerId,
    String projectName,
    String projectDescription,
    List<String> participants,
  );

  Future<void> createUser({required AuthorizedUser user});

  Future<void> declineFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> deleteDirectChat(String chatId);

  Future<void> deleteGroupChat(String chatId);

  Future<void> deleteProject(String projectId);

  Future<void> removeFriend({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> sendFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> updateDirectChatLastMessage({
    required String chatId,
    required String lastMessage,
  });

  Future<void> updateDirectChatUnreadCount({
    required String chatId,
    required int unreadCount,
  });

  Future<void> updateGroupChat(GroupChat chat);

  Future<void> updateGroupChatAvatarUrl({
    required String chatId,
    required String url,
  });

  Future<void> updateGroupChatLastMessage({
    required String chatId,
    required String lastMessage,
  });

  Future<void> updateGroupChatUnreadCounts({
    required String chatId,
    required Map<String, int> unreadCounts,
  });

  Future<void> updateProject(Project project);

  Future<void> updateUserAvatarUrl({
    required String userId,
    required String url,
  });

  Future<void> updateUserCurrentDirectChatId({
    required String userId,
    required String currentDirectChatId,
  });

  Future<void> updateUserCurrentGroupChatId({
    required String userId,
    required String currentGroupChatId,
  });

  Stream<List<Chat>?> watchAllChatsForUser(String userId);

  Stream<List<AuthorizedUser>?> watchAllUsers();

  Stream<List<DirectChat>?> watchDirectChatsForUser(String userId);

  Stream<int?> watchDirectChatUnreadCount({required String chatId});

  Stream<DirectChat?> watchDirectChatWithId(String chatId);

  Stream<List<AuthorizedUser>?> watchFriendIncomingRequestsForUser({
    required String userId,
  });

  Stream<List<AuthorizedUser>?> watchFriendOutgoingRequestsForUser({
    required String userId,
  });

  Stream<List<AuthorizedUser>?> watchFriendsForUser({required String userId});

  Stream<List<GroupChat>?> watchGroupChatsForUser(String userId);

  Stream<Map<String, int>?> watchGroupChatUnreadCounts({
    required String chatId,
  });

  Stream<GroupChat?> watchGroupChatWithId(String chatId);

  Stream<List<Message>?> watchMessagesForDirectChat({required String chatId});

  Stream<List<Message>?> watchMessagesForGroupChat({required String chatId});

  Stream<List<Project>?> watchProjectsForUser(String userId);

  Stream<Project?> watchProjectWithId(String projectId);
}
