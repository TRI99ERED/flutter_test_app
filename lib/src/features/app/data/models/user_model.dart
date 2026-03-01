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
  final String avatarUrl;

  const AuthorizedUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
  });

  bool get hasAvatar => avatarUrl.isNotEmpty;

  @override
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return AuthorizedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
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
            other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, avatarUrl);
}
