import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:test_app/l10n/locales/l10n.dart';

enum TaskStatus {
  todo,
  inProgress,
  finished;

  String displayName(BuildContext context) {
    switch (this) {
      case TaskStatus.todo:
        return context.l10n.toDoLabel;
      case TaskStatus.inProgress:
        return context.l10n.inProgressLabel;
      case TaskStatus.finished:
        return context.l10n.finishedLabel;
    }
  }
}

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${data['status'] ?? 'todo'}',
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${data['priority'] ?? 'low'}',
        orElse: () => TaskPriority.low,
      ),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        priority.hashCode;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
    };
  }
}
