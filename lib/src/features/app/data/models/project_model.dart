import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ProjectStatus {
  todo,
  inProgress,
  finished;

  String get displayName {
    switch (this) {
      case ProjectStatus.todo:
        return 'To Do';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.finished:
        return 'Finished';
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
  final DateTime createdAt;
  final DateTime lastUpdated;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.participants,
    required this.status,
    required this.createdAt,
    required this.lastUpdated,
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? participants,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
        other.createdAt == createdAt &&
        other.lastUpdated == lastUpdated;
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
      createdAt,
      lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'participants': participants,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
