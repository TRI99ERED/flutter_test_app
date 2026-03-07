import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

class FirebaseFirestoreRepositoryImpl implements IFirebaseFirestoreRepository {
  final _users = FirebaseFirestore.instance.collection('users');
  final _chats = FirebaseFirestore.instance.collection('chats');

  @override
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) {
    final currentUserDoc = _users.doc(currentUserId);
    final friendUserDoc = _users.doc(friendUserId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final currentUserSnapshot = await tx.get(currentUserDoc);
      final friendUserSnapshot = await tx.get(friendUserDoc);

      if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      tx.set(currentUserDoc.collection('friends').doc(friendUserId), {
        'id': friendUserId,
      });

      tx.set(friendUserDoc.collection('friends').doc(currentUserId), {
        'id': currentUserId,
      });

      tx.delete(
        currentUserDoc.collection('friendIncomingRequests').doc(friendUserId),
      );

      tx.delete(
        friendUserDoc.collection('friendOutgoingRequests').doc(currentUserId),
      );
    });
  }

  @override
  Future<void> cancelFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) {
    final currentUserDoc = _users.doc(currentUserId);
    final friendUserDoc = _users.doc(friendUserId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final currentUserSnapshot = await tx.get(currentUserDoc);
      final friendUserSnapshot = await tx.get(friendUserDoc);

      if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      tx.delete(
        currentUserDoc.collection('friendOutgoingRequests').doc(friendUserId),
      );

      tx.delete(
        friendUserDoc.collection('friendIncomingRequests').doc(currentUserId),
      );
    });
  }

  @override
  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) {
    final doc = _chats.doc(chatId).collection('messages').doc();

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
  Future<void> createUser({required AuthorizedUser user}) {
    final doc = _users.doc(user.id);
    return doc.set(user.toFirestore());
  }

  @override
  Future<void> declineFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) {
    final currentUserDoc = _users.doc(currentUserId);
    final friendUserDoc = _users.doc(friendUserId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final currentUserSnapshot = await tx.get(currentUserDoc);
      final friendUserSnapshot = await tx.get(friendUserDoc);

      if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      tx.delete(
        currentUserDoc.collection('friendIncomingRequests').doc(friendUserId),
      );

      tx.delete(
        friendUserDoc.collection('friendOutgoingRequests').doc(currentUserId),
      );
    });
  }

  @override
  Future<void> removeFriend({
    required String currentUserId,
    required String friendUserId,
  }) {
    final currentUserDoc = _users.doc(currentUserId);
    final friendUserDoc = _users.doc(friendUserId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final currentUserSnapshot = await tx.get(currentUserDoc);
      final friendUserSnapshot = await tx.get(friendUserDoc);

      if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      tx.delete(currentUserDoc.collection('friends').doc(friendUserId));

      tx.delete(friendUserDoc.collection('friends').doc(currentUserId));
    });
  }

  @override
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) {
    final currentUserDoc = _users.doc(currentUserId);
    final friendUserDoc = _users.doc(friendUserId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final currentUserSnapshot = await tx.get(currentUserDoc);
      final friendUserSnapshot = await tx.get(friendUserDoc);

      if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      tx.set(
        currentUserDoc.collection('friendOutgoingRequests').doc(friendUserId),
        {'id': friendUserId},
      );

      tx.set(
        friendUserDoc.collection('friendIncomingRequests').doc(currentUserId),
        {'id': currentUserId},
      );
    });
  }

  @override
  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) {
    return _chats.doc(chatId).update({
      'lastMessage': lastMessage,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) {
    return _chats.doc(chatId).update({'unreadCount': unreadCount});
  }

  @override
  Stream<List<AuthorizedUser>> watchAllUsers() {
    return _users.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => AuthorizedUser.fromFirestore(doc))
          .toList(),
    );
  }

  @override
  Stream<List<Chat>> watchChatsForUser(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Chat.fromFirestore).toList());
  }

  @override
  Stream<int> watchChatUnreadCount({required String chatId}) {
    return _chats.doc(chatId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return 0;
      return data['unreadCount'] ?? 0;
    });
  }

  @override
  Stream<List<AuthorizedUser>> watchFriendIncomingRequestsForUser({
    required String userId,
  }) {
    return _users
        .doc(userId)
        .collection('friendIncomingRequests')
        .snapshots()
        .asyncMap((snapshot) async {
          final users = await Future.wait(
            snapshot.docs.map((doc) async {
              final u = AuthorizedUser.fromFirestore(doc);
              final userDoc = await _users.doc(u.id).get();
              final data = userDoc.data() ?? {};
              return AuthorizedUser(
                id: u.id,
                name: data['name'] ?? '',
                email: data['email'] ?? '',
                handle: data['handle'] ?? '',
                avatarUrl: data['avatarUrl'] ?? '',
              );
            }).toList(),
          );
          return users;
        });
  }

  @override
  Stream<List<AuthorizedUser>> watchFriendOutgoingRequestsForUser({
    required String userId,
  }) {
    return _users
        .doc(userId)
        .collection('friendOutgoingRequests')
        .snapshots()
        .asyncMap((snapshot) async {
          final users = await Future.wait(
            snapshot.docs.map((doc) async {
              final u = AuthorizedUser.fromFirestore(doc);
              final userDoc = await _users.doc(u.id).get();
              final data = userDoc.data() ?? {};
              return AuthorizedUser(
                id: u.id,
                name: data['name'] ?? '',
                email: data['email'] ?? '',
                handle: data['handle'] ?? '',
                avatarUrl: data['avatarUrl'] ?? '',
              );
            }).toList(),
          );
          return users;
        });
  }

  @override
  Stream<List<AuthorizedUser>> watchFriendsForUser({required String userId}) {
    return _users.doc(userId).collection('friends').snapshots().asyncMap((
      snapshot,
    ) async {
      final users = await Future.wait(
        snapshot.docs.map((doc) async {
          final u = AuthorizedUser.fromFirestore(doc);
          final userDoc = await _users.doc(u.id).get();
          final data = userDoc.data() ?? {};
          return AuthorizedUser(
            id: u.id,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            handle: data['handle'] ?? '',
            avatarUrl: data['avatarUrl'] ?? '',
          );
        }).toList(),
      );
      return users;
    });
  }

  @override
  Stream<List<Message>> watchMessagesForChat({required String chatId}) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList());
  }
}
