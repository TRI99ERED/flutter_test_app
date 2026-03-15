import 'package:cloud_firestore/cloud_firestore.dart';

abstract base class UserEntity {
  const UserEntity();

  UserEntity copyWith();
}

final class UnauthorizedUser extends UserEntity {
  const UnauthorizedUser();

  @override
  UserEntity copyWith() => this;
}

final class AuthorizedUser extends UserEntity {
  final String id;
  final String name;
  final String email;
  final String handle;
  final String avatarUrl;
  final String currentDirectChatId;
  final String currentGroupChatId;
  final List<String> selectedInterests;
  final List<String> chatRecentSearches;
  final List<String> friendRecentSearches;
  final List<String> projectRecentSearches;

  const AuthorizedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    this.avatarUrl = '',
    this.currentDirectChatId = '',
    this.currentGroupChatId = '',
    this.selectedInterests = const [],
    this.chatRecentSearches = const [],
    this.friendRecentSearches = const [],
    this.projectRecentSearches = const [],
  });

  factory AuthorizedUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AuthorizedUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      handle: data['handle'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      currentDirectChatId: data['currentDirectChatId'] ?? '',
      currentGroupChatId: data['currentGroupChatId'] ?? '',
      selectedInterests: List<String>.from(data['selectedInterests'] ?? []),
      chatRecentSearches: List<String>.from(data['chatRecentSearches'] ?? []),
      friendRecentSearches: List<String>.from(
        data['friendRecentSearches'] ?? [],
      ),
      projectRecentSearches: List<String>.from(
        data['projectRecentSearches'] ?? [],
      ),
    );
  }

  bool get hasAvatar => avatarUrl.isNotEmpty;

  @override
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? handle,
    String? avatarUrl,
    String? currentDirectChatId,
    String? currentGroupChatId,
    List<String>? selectedInterests,
    List<String>? chatRecentSearches,
    List<String>? friendRecentSearches,
    List<String>? projectRecentSearches,
  }) {
    return AuthorizedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentDirectChatId: currentDirectChatId ?? this.currentDirectChatId,
      currentGroupChatId: currentGroupChatId ?? this.currentGroupChatId,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      chatRecentSearches: chatRecentSearches ?? this.chatRecentSearches,
      friendRecentSearches: friendRecentSearches ?? this.friendRecentSearches,
      projectRecentSearches:
          projectRecentSearches ?? this.projectRecentSearches,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthorizedUser &&
            other.id == id &&
            other.name == name &&
            other.email == email &&
            other.handle == handle &&
            other.avatarUrl == avatarUrl &&
            other.currentDirectChatId == currentDirectChatId &&
            other.currentGroupChatId == currentGroupChatId &&
            other.selectedInterests == selectedInterests &&
            other.chatRecentSearches == chatRecentSearches &&
            other.friendRecentSearches == friendRecentSearches &&
            other.projectRecentSearches == projectRecentSearches;
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    handle,
    avatarUrl,
    currentDirectChatId,
    currentGroupChatId,
    selectedInterests,
    chatRecentSearches,
    friendRecentSearches,
    projectRecentSearches,
  );

  @override
  String toString() {
    return 'AuthorizedUser{id: $id, name: $name,handle: $handle}';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'handle': handle,
      'avatarUrl': avatarUrl,
      'currentDirectChatId': currentDirectChatId,
      'currentGroupChatId': currentGroupChatId,
      'selectedInterests': selectedInterests,
      'chatRecentSearches': chatRecentSearches,
      'friendRecentSearches': friendRecentSearches,
      'projectRecentSearches': projectRecentSearches,
    };
  }
}
