import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/src/features/chat_screen/chat_screen.dart';

base class Message {
  final String id;
  final String senderId;
  final String body;
  final List<String> imageUrls;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.body,
    this.imageUrls = const [],
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      body: data['body'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? body,
    List<String>? imageUrls,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      imageUrls: imageUrls ?? this.imageUrls,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.senderId == senderId &&
        other.body == body &&
        ListEquality().equals(other.imageUrls, imageUrls) &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      senderId,
      body,
      Object.hashAll(imageUrls),
      timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'body': body,
      'imageUrls': imageUrls,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

final class SavedMessage extends Message {
  final String chatId;
  final ChatType chatType;
  final DateTime savedAt;

  const SavedMessage({
    required super.id,
    required super.senderId,
    required super.body,
    required super.imageUrls,
    required super.timestamp,
    required this.chatId,
    required this.chatType,
    required this.savedAt,
  });

  factory SavedMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SavedMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      body: data['body'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      chatId: data['chatId'] ?? '',
      chatType: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${data['chatType']}',
        orElse: () => ChatType.direct,
      ),
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  SavedMessage copyWith({
    String? id,
    String? senderId,
    String? body,
    List<String>? imageUrls,
    DateTime? timestamp,
    String? chatId,
    ChatType? chatType,
    DateTime? savedAt,
  }) {
    return SavedMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      imageUrls: imageUrls ?? this.imageUrls,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavedMessage &&
        super == other &&
        other.chatId == chatId &&
        other.chatType == chatType &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode {
    return Object.hash(super.hashCode, chatId, chatType, savedAt);
  }

  @override
  Map<String, dynamic> toFirestore() {
    final baseData = super.toFirestore();
    return {
      ...baseData,
      'chatId': chatId,
      'chatType': chatType.toString().split('.').last,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}
