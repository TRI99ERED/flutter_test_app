import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

class FirebaseFirestoreRepositoryImpl implements IFirebaseFirestoreRepository {
  final _chats = FirebaseFirestore.instance.collection('chats');

  @override
  Stream<List<Chat>> watchChatsForUser(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Chat.fromFirestore).toList());
  }

  @override
  Future<String> createOrGetDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    final ids = [currentUserId, otherUserId]..sort();
    final chatId = ids.join('_');
    final doc = _chats.doc(chatId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(doc);
      if (snapshot.exists) {
        return;
      }

      tx.set(doc, {
        'participants': ids,
        'participantNames': {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });

    return chatId;
  }

  @override
  Stream<List<AuthorizedUser>> watchAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuthorizedUser.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> createUser(AuthorizedUser user) {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.id);
    return doc.set(user.toFirestore());
  }

  @override
  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) {
    final doc = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = Message(
      id: doc.id,
      senderId: senderId,
      senderName: senderName,
      body: body,
      timestamp: DateTime.now(),
    );
    return doc.set(message.toFirestore());
  }

  @override
  Stream<List<Message>> watchMessagesForChat(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList());
  }

  @override
  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) {
    return FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': lastMessage,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
