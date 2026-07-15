import '../../domain/entities/app_user.dart';

/// Payload for the `POST /accounts/register/` endpoint.
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role.name,
      };
}
