import '../../domain/entities/app_user.dart';

/// Data-transfer object for user data received from the API.
///
/// Must not leak outside the data layer. Convert to [AppUser] via [toDomain].
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      // Support both snake_case (Django) and camelCase field names.
      fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
      role: (json['role'] ?? 'student') as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Maps this DTO to the [AppUser] domain entity.
  AppUser toDomain() {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName,
      role: UserRole.fromString(role),
      avatarUrl: avatarUrl,
    );
  }
}
