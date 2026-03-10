import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Chat {
  final String id;
  final String name;
  final String groupOwnerId;
  final List<String> participants;
  final String lastMessage;
  final int unreadCount;
  final DateTime lastUpdated;

  const Chat({
    required this.id,
    required this.name,
    this.groupOwnerId = '',
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
    required this.lastUpdated,
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Chat(
      id: doc.id,
      name: data['name'] ?? '',
      groupOwnerId: data['groupOwnerId'] ?? '',
      participants: List<String>.from(data['participants'] ?? const []),
      lastMessage: data['lastMessage'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Chat copyWith({
    String? id,
    String? name,
    String? groupOwnerId,
    List<String>? participants,
    String? lastMessage,
    int? unreadCount,
    DateTime? lastUpdated,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      groupOwnerId: groupOwnerId ?? this.groupOwnerId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.id == id &&
        other.name == name &&
        other.groupOwnerId == groupOwnerId &&
        listEquals(other.participants, participants) &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      groupOwnerId,
      Object.hashAll(participants),
      lastMessage,
      unreadCount,
      lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'groupOwnerId': groupOwnerId,
      'participants': participants,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
