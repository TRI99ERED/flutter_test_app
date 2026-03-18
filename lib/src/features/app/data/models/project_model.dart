import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';

enum ProjectStatus {
  todo,
  inProgress,
  finished;

  String displayName(BuildContext context) {
    switch (this) {
      case ProjectStatus.todo:
        return context.l10n.toDoLabel;
      case ProjectStatus.inProgress:
        return context.l10n.inProgressLabel;
      case ProjectStatus.finished:
        return context.l10n.finishedLabel;
    }
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> participants;
  final ProjectStatus status;
  final String groupChatId;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final DateTime deadline;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.participants,
    required this.status,
    this.groupChatId = '',
    required this.createdAt,
    required this.lastUpdated,
    required this.deadline,
  });

  factory Project.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      participants: List<String>.from(data['participants'] ?? const []),
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == 'ProjectStatus.${data['status'] ?? 'todo'}',
        orElse: () => ProjectStatus.todo,
      ),
      groupChatId: data['groupChatId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? participants,
    ProjectStatus? status,
    String? groupChatId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? deadline,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      groupChatId: groupChatId ?? this.groupChatId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.ownerId == ownerId &&
        listEquals(other.participants, participants) &&
        other.status == status &&
        other.groupChatId == groupChatId &&
        other.createdAt == createdAt &&
        other.lastUpdated == lastUpdated &&
        other.deadline == deadline;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      ownerId,
      Object.hashAll(participants),
      status,
      groupChatId,
      createdAt,
      lastUpdated,
      deadline,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'participants': participants,
      'status': status.toString().split('.').last,
      'groupChatId': groupChatId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'deadline': Timestamp.fromDate(deadline),
    };
  }
}
