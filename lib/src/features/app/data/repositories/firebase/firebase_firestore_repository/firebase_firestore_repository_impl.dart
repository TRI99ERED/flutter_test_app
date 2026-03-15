import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/project_feedback_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

class FirebaseFirestoreRepositoryImpl implements IFirebaseFirestoreRepository {
  final _users = FirebaseFirestore.instance.collection('users');
  final _directChats = FirebaseFirestore.instance.collection('directChats');
  final _groupChats = FirebaseFirestore.instance.collection('groupChats');
  final _projects = FirebaseFirestore.instance.collection('projects');

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
  Future<DirectChat> createDirectChat({
    required List<String> participants,
    required String chatName,
  }) async {
    try {
      final ids = participants..sort();
      final doc = _directChats.doc();

      final directChat = DirectChat(
        id: doc.id,
        name: chatName,
        participants: ids,
        lastMessage: '',
        unreadCount: 0,
        lastUpdated: DateTime.now(),
      );
      await doc.set(directChat.toFirestore());
      return directChat;
    } catch (e) {
      throw Exception('Failed to create or get direct chat: $e');
    }
  }

  @override
  Future<Message> createDirectChatMessage({
    required String chatId,
    required String senderId,
    required String body,
  }) async {
    try {
      final doc = _directChats.doc(chatId).collection('messages').doc();

      final message = Message(
        id: doc.id,
        senderId: senderId,
        body: body,
        timestamp: DateTime.now(),
      );
      await doc.set(message.toFirestore());
      return message;
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  @override
  Future<GroupChat> createGroupChat({
    required List<String> participants,
    required String chatName,
    required String ownerId,
  }) async {
    try {
      final ids = participants..sort();
      final doc = _groupChats.doc();

      final groupChat = GroupChat(
        id: doc.id,
        name: chatName,
        participants: ids,
        ownerId: ownerId,
        lastMessage: '',
        avatarUrl: '',
        unreadCounts: {for (var id in ids) id: 0},
        lastUpdated: DateTime.now(),
      );
      await doc.set(groupChat.toFirestore());
      return groupChat;
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  @override
  Future<Message> createGroupChatMessage({
    required String chatId,
    required String senderId,
    required String body,
  }) async {
    try {
      final doc = _groupChats.doc(chatId).collection('messages').doc();

      final message = Message(
        id: doc.id,
        senderId: senderId,
        body: body,
        timestamp: DateTime.now(),
      );
      await doc.set(message.toFirestore());
      return message;
    } catch (e) {
      throw Exception('Failed to create message: $e');
    }
  }

  @override
  Future<Project> createProjectForUser(
    String ownerId,
    String projectName,
    String projectDescription,
    List<String> participants,
    DateTime deadline,
  ) async {
    try {
      final doc = _projects.doc();

      final project = Project(
        id: doc.id,
        ownerId: ownerId,
        name: projectName,
        description: projectDescription,
        participants: participants,
        status: ProjectStatus.todo,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        deadline: deadline,
      );
      await doc.set(project.toFirestore());
      return project;
    } catch (e) {
      throw Exception('Failed to create project: $e');
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
  Future<void> deleteDirectChat(String chatId) async {
    final doc = _directChats.doc(chatId);
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
  Future<void> deleteGroupChat(String chatId) async {
    final doc = _groupChats.doc(chatId);
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
  Future<void> deleteProject(String projectId) async {
    final doc = _projects.doc(projectId);
    try {
      await doc.delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  @override
  Future<bool> doesUserExist(String id) {
    return _users.doc(id).get().then((doc) => doc.exists).catchError((e) {
      throw Exception('Failed to check if user exists: $e');
    });
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
  Future<ProjectFeedback> submitProjectFeedback({
    required String projectId,
    required String userId,
    required int starRating,
    required Set<String> likes,
    required Set<String> dislikes,
    required String feedback,
  }) async {
    try {
      final doc = _projects.doc(projectId).collection('feedback').doc(userId);

      final projectFeedback = ProjectFeedback(
        feedbackId: doc.id,
        projectId: projectId,
        userId: userId,
        starRating: starRating,
        likes: likes,
        dislikes: dislikes,
        feedback: feedback,
      );
      await doc.set(projectFeedback.toFirestore());
      return projectFeedback;
    } catch (e) {
      throw Exception('Failed to submit project feedback: $e');
    }
  }

  @override
  Future<void> updateDirectChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async {
    try {
      await _directChats.doc(chatId).update({
        'lastMessage': lastMessage,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update direct chat last message: $e');
    }
  }

  @override
  Future<void> updateDirectChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async {
    try {
      await _directChats.doc(chatId).update({'unreadCount': unreadCount});
    } catch (e) {
      throw Exception('Failed to update direct chat unread count: $e');
    }
  }

  @override
  Future<void> updateGroupChat(GroupChat chat) async {
    try {
      await _groupChats.doc(chat.id).update(chat.toFirestore());
    } catch (e) {
      throw Exception('Failed to update group chat: $e');
    }
  }

  @override
  Future<void> updateGroupChatAvatarUrl({
    required String chatId,
    required String url,
  }) async {
    try {
      await _groupChats.doc(chatId).update({'avatarUrl': url});
    } catch (e) {
      throw Exception('Failed to update group chat avatar URL: $e');
    }
  }

  @override
  Future<void> updateGroupChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async {
    try {
      await _groupChats.doc(chatId).update({
        'lastMessage': lastMessage,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update group chat last message: $e');
    }
  }

  @override
  Future<void> updateGroupChatUnreadCounts({
    required String chatId,
    required Map<String, int> unreadCounts,
  }) async {
    try {
      final docRef = _groupChats.doc(chatId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Group chat does not exist');
        }
        final currentCounts = Map<String, int>.from(
          snapshot.data()?['unreadCounts'] ?? {},
        );
        unreadCounts.forEach((key, value) {
          currentCounts[key] = value;
        });
        tx.update(docRef, {'unreadCounts': currentCounts});
      });
    } catch (e) {
      throw Exception('Failed to update group chat unread counts: $e');
    }
  }

  @override
  Future<void> updateProject(Project project) {
    try {
      return _projects.doc(project.id).update(project.toFirestore());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  @override
  Future<void> updateUser(AuthorizedUser updatedUser) {
    try {
      return _users.doc(updatedUser.id).update(updatedUser.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> updateUserAvatarUrl({
    required String userId,
    required String url,
  }) {
    try {
      return _users.doc(userId).update({'avatarUrl': url});
    } catch (e) {
      throw Exception('Failed to update user avatar URL: $e');
    }
  }

  @override
  Future<void> updateUserCurrentDirectChatId({
    required String userId,
    required String currentDirectChatId,
  }) {
    try {
      return _users.doc(userId).update({
        'currentDirectChatId': currentDirectChatId,
      });
    } catch (e) {
      throw Exception('Failed to update user current direct chat ID: $e');
    }
  }

  @override
  Future<void> updateUserCurrentGroupChatId({
    required String userId,
    required String currentGroupChatId,
  }) {
    try {
      return _users.doc(userId).update({
        'currentGroupChatId': currentGroupChatId,
      });
    } catch (e) {
      throw Exception('Failed to update user current group chat ID: $e');
    }
  }

  @override
  Stream<List<Chat>?> watchAllChatsForUser(String userId) {
    final directChatsStream = watchDirectChatsForUser(userId);
    final groupChatsStream = watchGroupChatsForUser(userId);

    return Rx.combineLatest2<List<Chat>?, List<Chat>?, List<Chat>?>(
      directChatsStream,
      groupChatsStream,
      (directChats, groupChats) {
        final allChats = <Chat>[...?directChats, ...?groupChats];
        allChats.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        return allChats;
      },
    ).distinct((prev, next) {
      if (prev == null || next == null) return prev == next;
      if (prev.length != next.length) return false;
      final prevIds = prev.map((c) => c.id).toSet();
      final nextIds = next.map((c) => c.id).toSet();
      return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
    });
  }

  @override
  Stream<List<AuthorizedUser>?> watchAllUsers() {
    return _users
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuthorizedUser.fromFirestore(doc))
              .toList(),
        )
        .distinct(
          (prev, next) =>
              prev.length == next.length &&
              prev.every((user) => next.any((u) => u == user)),
        );
  }

  @override
  Stream<List<DirectChat>?> watchDirectChatsForUser(String userId) {
    return _directChats
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(DirectChat.fromFirestore).toList())
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((c) => c.id).toSet();
          final nextIds = next.map((c) => c.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<int?> watchDirectChatUnreadCount({required String chatId}) {
    return _directChats
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return data['unreadCount'] ?? 0;
        })
        .distinct((prev, next) => prev == next)
        .cast<int?>();
  }

  @override
  Stream<DirectChat?> watchDirectChatWithId(String chatId) {
    return _directChats
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          return DirectChat.fromFirestore(snapshot);
        })
        .distinct((prev, next) => prev == next);
  }

  @override
  Stream<List<AuthorizedUser>?> watchFriendIncomingRequestsForUser({
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
        })
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((u) => u.id).toSet();
          final nextIds = next.map((u) => u.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<List<AuthorizedUser>?> watchFriendOutgoingRequestsForUser({
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
        })
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((u) => u.id).toSet();
          final nextIds = next.map((u) => u.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<List<AuthorizedUser>?> watchFriendsForUser({required String userId}) {
    return _users
        .doc(userId)
        .collection('friends')
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
        })
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((u) => u.id).toSet();
          final nextIds = next.map((u) => u.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<List<GroupChat>?> watchGroupChatsForUser(String userId) {
    return _groupChats
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(GroupChat.fromFirestore).toList())
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((c) => c.id).toSet();
          final nextIds = next.map((c) => c.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<Map<String, int>?> watchGroupChatUnreadCounts({
    required String chatId,
  }) {
    return _groupChats
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return Map<String, int>.from(data['unreadCounts'] ?? {});
        })
        .distinct((prev, next) {
          if (prev == null || next == null) return prev == next;
          if (prev.length != next.length) return false;
          final prevKeys = prev.keys.toSet();
          final nextKeys = next.keys.toSet();
          if (!prevKeys.containsAll(nextKeys) ||
              !nextKeys.containsAll(prevKeys)) {
            return false;
          }
          for (final key in prevKeys) {
            if (prev[key] != next[key]) {
              return false;
            }
          }
          return true;
        })
        .cast<Map<String, int>?>();
  }

  @override
  Stream<GroupChat?> watchGroupChatWithId(String chatId) {
    return _groupChats
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          return GroupChat.fromFirestore(snapshot);
        })
        .distinct((prev, next) => prev == next);
  }

  @override
  Stream<List<Message>?> watchMessagesForDirectChat({required String chatId}) {
    return _directChats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList())
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((m) => m.id).toSet();
          final nextIds = next.map((m) => m.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<List<Message>?> watchMessagesForGroupChat({required String chatId}) {
    return _groupChats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList())
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((m) => m.id).toSet();
          final nextIds = next.map((m) => m.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<List<Project>?> watchProjectsForUser(
    String userId,
    String orderBy,
    bool descending,
  ) {
    return _projects
        .where('participants', arrayContains: userId)
        .orderBy(orderBy, descending: descending)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Project.fromFirestore).toList())
        .distinct((prev, next) {
          if (prev.length != next.length) return false;
          final prevIds = prev.map((p) => p.id).toSet();
          final nextIds = next.map((p) => p.id).toSet();
          return prevIds.containsAll(nextIds) && nextIds.containsAll(prevIds);
        });
  }

  @override
  Stream<Project?> watchProjectWithId(String projectId) {
    return _projects
        .doc(projectId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          return Project.fromFirestore(snapshot);
        })
        .distinct((prev, next) => prev == next);
  }
}
