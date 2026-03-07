import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserEntity {
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

  const AuthorizedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    this.avatarUrl = '',
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
  }) {
    return AuthorizedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
            other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, handle, avatarUrl);

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'handle': handle,
      'avatarUrl': avatarUrl,
    };
  }
}
