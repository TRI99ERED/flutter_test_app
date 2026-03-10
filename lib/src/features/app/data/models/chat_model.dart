import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract base class Chat {
  final String id;
  final String name;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdated;

  const Chat({
    required this.id,
    required this.name,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.id == id &&
        other.name == name &&
        listEquals(other.participants, participants) &&
        other.lastMessage == lastMessage &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      Object.hashAll(participants),
      lastMessage,
      lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

final class DirectChat extends Chat {
  final int unreadCount;

  const DirectChat({
    required super.id,
    required super.name,
    required super.participants,
    required super.lastMessage,
    required super.lastUpdated,
    required this.unreadCount,
  });

  factory DirectChat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DirectChat(
      id: doc.id,
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? const []),
      lastMessage: data['lastMessage'] ?? '',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Chat copyWith({
    String? id,
    String? name,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastUpdated,
    int? unreadCount,
  }) {
    return DirectChat(
      id: id ?? this.id,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DirectChat &&
        super == other &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, unreadCount);

  @override
  Map<String, dynamic> toFirestore() {
    final data = super.toFirestore();
    data['unreadCount'] = unreadCount;
    return data;
  }
}

final class GroupChat extends Chat {
  final String ownerId;
  final String avatarUrl;
  final Map<String, int> unreadCounts;

  const GroupChat({
    required super.id,
    required super.name,
    required super.participants,
    required super.lastMessage,
    required super.lastUpdated,
    required this.ownerId,
    required this.avatarUrl,
    required this.unreadCounts,
  });

  factory GroupChat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GroupChat(
      id: doc.id,
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? const []),
      lastMessage: data['lastMessage'] ?? '',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: data['ownerId'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? const {}),
    );
  }

  Chat copyWith({
    String? id,
    String? name,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastUpdated,
    String? ownerId,
    String? avatarUrl,
    Map<String, int>? unreadCounts,
  }) {
    return GroupChat(
      id: id ?? this.id,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      ownerId: ownerId ?? this.ownerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupChat &&
        super == other &&
        other.ownerId == ownerId &&
        other.avatarUrl == avatarUrl &&
        mapEquals(other.unreadCounts, unreadCounts);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    ownerId,
    avatarUrl,
    Object.hashAll(unreadCounts.entries),
  );

  @override
  Map<String, dynamic> toFirestore() {
    final data = super.toFirestore();
    data['ownerId'] = ownerId;
    data['avatarUrl'] = avatarUrl;
    data['unreadCounts'] = unreadCounts;
    return data;
  }
}
