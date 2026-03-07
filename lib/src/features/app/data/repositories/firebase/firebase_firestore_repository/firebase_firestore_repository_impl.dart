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
  }) async {
    try {
      final currentUserDoc = _users.doc(currentUserId);
      final friendUserDoc = _users.doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
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
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> cancelFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) async {
    try {
      final currentUserDoc = _users.doc(currentUserId);
      final friendUserDoc = _users.doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
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
    } catch (e) {
      throw Exception('Failed to cancel friend request: $e');
    }
  }

  @override
  Future<void> createMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
  }) async {
    try {
      final doc = _chats.doc(chatId).collection('messages').doc();

      final message = Message(
        id: doc.id,
        senderId: senderId,
        senderName: senderName,
        body: body,
        timestamp: DateTime.now(),
      );
      await doc.set(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  @override
  Future<String> createOrGetDirectChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to create or get direct chat: $e');
    }
  }

  @override
  Future<void> createUser({required AuthorizedUser user}) {
    final doc = _users.doc(user.id);
    try {
      return doc.set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> declineFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) async {
    try {
      final currentUserDoc = _users.doc(currentUserId);
      final friendUserDoc = _users.doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
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
    } catch (e) {
      throw Exception('Failed to decline friend request: $e');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final doc = _chats.doc(chatId);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(doc);

        if (!snapshot.exists) {
          throw Exception('Chat does not exist');
        }

        final messagesSnapshot = await doc.collection('messages').get();
        for (final messageDoc in messagesSnapshot.docs) {
          tx.delete(messageDoc.reference);
        }

        tx.delete(doc);
      });
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  @override
  Future<void> removeFriend({
    required String currentUserId,
    required String friendUserId,
  }) async {
    try {
      final currentUserDoc = _users.doc(currentUserId);
      final friendUserDoc = _users.doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final currentUserSnapshot = await tx.get(currentUserDoc);
        final friendUserSnapshot = await tx.get(friendUserDoc);

        if (!currentUserSnapshot.exists || !friendUserSnapshot.exists) {
          throw Exception('One or both users do not exist');
        }

        tx.delete(currentUserDoc.collection('friends').doc(friendUserId));

        tx.delete(friendUserDoc.collection('friends').doc(currentUserId));
      });
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  @override
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String friendUserId,
  }) async {
    try {
      final currentUserDoc = _users.doc(currentUserId);
      final friendUserDoc = _users.doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((tx) async {
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
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async {
    try {
      await _chats.doc(chatId).update({
        'lastMessage': lastMessage,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update chat last message: $e');
    }
  }

  @override
  Future<void> updateChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async {
    try {
      await _chats.doc(chatId).update({'unreadCount': unreadCount});
    } catch (e) {
      throw Exception('Failed to update chat unread count: $e');
    }
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
