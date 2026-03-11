import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String body;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.body,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? body,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
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
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, senderId, body, timestamp);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
