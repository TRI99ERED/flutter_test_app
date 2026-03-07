import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Chat {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final int unreadCount;
  final DateTime lastUpdated;

  const Chat({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.unreadCount,
    required this.lastUpdated,
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? const []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? const {},
      ),
      lastMessage: data['lastMessage'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Chat copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    String? lastMessage,
    int? unreadCount,
    DateTime? lastUpdated,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
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
        listEquals(other.participants, participants) &&
        mapEquals(other.participantNames, participantNames) &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      Object.hashAll(participants),
      Object.hashAll(participantNames.entries),
      lastMessage,
      unreadCount,
      lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
