import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';

/// Concrete implementation of [IAuthRepository].
///
/// Responsibilities:
/// - Delegates network calls to [AuthRemoteDataSource].
/// - Maps DTOs to domain entities (no raw JSON escapes this class).
/// - Persists / reads token pairs via [SecureStorageService].
/// - Wraps all exceptions in [ApiResult] so callers never receive raw errors.
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storage,
  })  : _remote = remoteDataSource,
        _storage = storage;

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  // ---------------------------------------------------------------------------
  // IAuthRepository
  // ---------------------------------------------------------------------------

  @override
  Future<ApiResult<AuthSession>> login(String email, String password) =>
      _execute(() async {
        final dto = await _remote.login(
          LoginRequestDto(email: email, password: password),
        );
        final tokens = dto.toTokensDomain();
        await _storage.saveTokens(
          access: tokens.accessToken,
          refresh: tokens.refreshToken,
        );
        return AuthSession(user: dto.user.toDomain(), tokens: tokens);
      });

  @override
  Future<ApiResult<AuthSession>> register(RegisterRequestDto params) =>
      _execute(() async {
        final dto = await _remote.register(params);
        final tokens = dto.toTokensDomain();
        await _storage.saveTokens(
          access: tokens.accessToken,
          refresh: tokens.refreshToken,
        );
        return AuthSession(user: dto.user.toDomain(), tokens: tokens);
      });

  @override
  Future<ApiResult<void>> logout() => _execute(() async {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          try {
            await _remote.logout(refreshToken);
          } catch (_) {
            // Server-side logout errors are intentionally swallowed; the user
            // is always logged out locally regardless of server state.
          }
        }
        await _storage.clearTokens();
      });

  @override
  Future<ApiResult<AuthTokens>> refreshToken() => _execute(() async {
        final stored = await _storage.getRefreshToken();
        if (stored == null) {
          throw const UnauthorizedException(
            message: 'No refresh token available. Please log in again.',
          );
        }
        final tokens = await _remote.refreshToken(stored);
        await _storage.saveTokens(
          access: tokens.accessToken,
          refresh: tokens.refreshToken,
        );
        return tokens;
      });

  @override
  Future<ApiResult<AuthSession?>> restoreSession() => _execute(() async {
        final accessToken = await _storage.getAccessToken();
        final refreshToken = await _storage.getRefreshToken();

        if (accessToken == null || refreshToken == null) return null;

        // Fetch the authenticated user's profile. The [AuthInterceptor] will
        // silently refresh the access token if it has expired before this
        // request completes.
        final userDto = await _remote.getProfile();
        return AuthSession(
          user: userDto.toDomain(),
          tokens: AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      });

  // ---------------------------------------------------------------------------
  // Error mapping helpers
  // ---------------------------------------------------------------------------

  Future<ApiResult<T>> _execute<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on ApiException catch (e) {
      return Failure(e);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  ApiException _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const RequestTimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse =>
        _mapStatusCode(e.response?.statusCode, e.response?.data),
      _ => UnknownException(message: e.message ?? 'Unexpected network error.'),
    };
  }

  ApiException _mapStatusCode(int? statusCode, dynamic data) {
    final message = _extractMessage(data);
    return switch (statusCode) {
      400 => ValidationException(message: message ?? 'Invalid request data.'),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      int s when s >= 500 => const ServerException(),
      _ => UnknownException(message: message ?? 'Unexpected server response.'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      // Django REST Framework error format
      return data['detail'] as String? ??
          data['message'] as String? ??
          data['error'] as String?;
    }
    return null;
  }
}
