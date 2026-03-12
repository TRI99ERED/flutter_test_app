import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProjectFeedback {
  final String feedbackId;
  final String projectId;
  final String userId;
  final int starRating;
  final Set<String> likes;
  final Set<String> dislikes;
  final String feedback;

  const ProjectFeedback({
    required this.feedbackId,
    required this.projectId,
    required this.userId,
    required this.starRating,
    required this.likes,
    required this.dislikes,
    required this.feedback,
  });

  factory ProjectFeedback.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ProjectFeedback(
      feedbackId: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      starRating: data['starRating'] ?? 0,
      likes: Set<String>.from(data['likes'] ?? const []),
      dislikes: Set<String>.from(data['dislikes'] ?? const []),
      feedback: data['feedback'] ?? '',
    );
  }

  ProjectFeedback copyWith({
    String? projectId,
    String? userId,
    int? starRating,
    Set<String>? likes,
    Set<String>? dislikes,
    String? feedback,
  }) {
    return ProjectFeedback(
      feedbackId: feedbackId,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      starRating: starRating ?? this.starRating,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProjectFeedback &&
        other.feedbackId == feedbackId &&
        other.projectId == projectId &&
        other.userId == userId &&
        other.starRating == starRating &&
        setEquals(other.likes, likes) &&
        setEquals(other.dislikes, dislikes) &&
        other.feedback == feedback;
  }

  @override
  int get hashCode {
    return Object.hash(
      feedbackId,
      projectId,
      userId,
      starRating,
      Object.hashAll(likes),
      Object.hashAll(dislikes),
      feedback,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'starRating': starRating,
      'likes': likes.toList(),
      'dislikes': dislikes.toList(),
      'feedback': feedback,
    };
  }
}
