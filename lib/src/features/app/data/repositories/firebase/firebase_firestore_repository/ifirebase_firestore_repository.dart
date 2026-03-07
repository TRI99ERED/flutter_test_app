import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
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

  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  });

  Future<String> createOrGetDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  });

  Future<void> createUser({required AuthorizedUser user});

  Future<void> declineFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> removeFriend({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> sendFriendRequest({
    required String currentUserId,
    required String friendUserId,
  });

  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  });

  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  });

  Stream<List<AuthorizedUser>> watchAllUsers();

  Stream<List<Chat>> watchChatsForUser(String userId);

  Stream<int> watchChatUnreadCount({required String chatId});

  Stream<List<AuthorizedUser>> watchFriendIncomingRequestsForUser({
    required String userId,
  });

  Stream<List<AuthorizedUser>> watchFriendOutgoingRequestsForUser({
    required String userId,
  });

  Stream<List<AuthorizedUser>> watchFriendsForUser({required String userId});

  Stream<List<Message>> watchMessagesForChat({required String chatId});
}
