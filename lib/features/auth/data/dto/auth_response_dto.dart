import '../../domain/entities/auth_tokens.dart';
import 'user_dto.dart';

/// Data-transfer object for authentication responses from:
/// - `POST /accounts/token/`
/// - `POST /accounts/register/`
///
/// Must not leak outside the data layer.
class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserDto user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      // Support both DRF SimpleJWT field names.
      accessToken: (json['access'] ?? json['access_token']) as String,
      refreshToken: (json['refresh'] ?? json['refresh_token']) as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Converts this DTO's token fields to the [AuthTokens] domain value object.
  AuthTokens toTokensDomain() => AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
