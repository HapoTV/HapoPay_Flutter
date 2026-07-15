/// Roles available within the HapoPay platform.
enum UserRole {
  parent,
  student;

  /// Maps a raw API string to a [UserRole], defaulting to [student].
  static UserRole fromString(String value) {
    return switch (value.toLowerCase()) {
      'parent' => UserRole.parent,
      _ => UserRole.student,
    };
  }
}

/// Immutable domain entity representing an authenticated user.
///
/// This is the single source of truth for user identity within the app.
/// Never store raw JSON outside the data layer — always map to [AppUser].
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;

  bool get isParent => role == UserRole.parent;
  bool get isStudent => role == UserRole.student;

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AppUser(id: $id, email: $email, role: $role)';
}
