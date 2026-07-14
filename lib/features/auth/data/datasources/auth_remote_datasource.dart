import 'package:dio/dio.dart';

import '../../domain/entities/auth_tokens.dart';
import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/user_dto.dart';

/// Handles all raw HTTP communication with the authentication endpoints.
///
/// Returns unvalidated DTOs. Mapping to domain entities and error handling
/// are delegated to [AuthRepositoryImpl].
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// `POST /accounts/token/`
  Future<AuthResponseDto> login(LoginRequestDto dto) async {
    final response = await _dio.post(
      '/accounts/token/',
      data: dto.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// `POST /accounts/register/`
  Future<AuthResponseDto> register(RegisterRequestDto dto) async {
    final response = await _dio.post(
      '/accounts/register/',
      data: dto.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// `POST /accounts/logout/`
  ///
  /// Blacklists the refresh token on the server.
  Future<void> logout(String refreshToken) async {
    await _dio.post(
      '/accounts/logout/',
      data: {'refresh': refreshToken},
    );
  }

  /// `POST /accounts/token/refresh/`
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/accounts/token/refresh/',
      data: {'refresh': refreshToken},
    );
    return AuthTokens(
      accessToken: response.data['access'] as String,
      refreshToken: (response.data['refresh'] as String?) ?? refreshToken,
    );
  }

  /// `GET /accounts/me/`
  ///
  /// Returns the profile of the currently authenticated user.
  /// The [AuthInterceptor] will transparently refresh the access token if
  /// it has expired before this request completes.
  Future<UserDto> getProfile() async {
    final response = await _dio.get('/accounts/me/');
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }
}
