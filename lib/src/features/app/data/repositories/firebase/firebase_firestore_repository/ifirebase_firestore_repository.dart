import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';

abstract interface class IFirebaseFirestoreRepository {
  Stream<List<Chat>> watchChatsForUser(String userId);

  Future<String> createOrGetDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  });

  Stream<List<AuthorizedUser>> watchAllUsers();

  Future<void> createUser(AuthorizedUser user);

  Stream<List<Message>> watchMessagesForChat(String chatId);

  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  });

  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  });

  Stream<int> watchChatUnreadCount(String chatId);

  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  });
}
