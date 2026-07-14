import '../../../../core/network/api_result.dart';
import '../entities/auth_session.dart';
import '../entities/auth_tokens.dart';
import '../../data/dto/register_request_dto.dart';

/// Contract for all authentication operations.
///
/// Depend on this interface in higher layers (notifiers, view-models) rather
/// than on [AuthRepositoryImpl] directly, enabling straightforward unit testing
/// with mock implementations.
abstract interface class IAuthRepository {
  /// Authenticates with [email] and [password].
  ///
  /// On success, persists the token pair in secure storage and returns an
  /// [AuthSession]. Returns a [Failure] with a user-safe [ApiException] on
  /// any error.
  Future<ApiResult<AuthSession>> login(String email, String password);

  /// Registers a new user account using [params].
  ///
  /// On success, persists the token pair and returns an [AuthSession].
  Future<ApiResult<AuthSession>> register(RegisterRequestDto params);

  /// Invalidates the session on the server and clears all local tokens.
  ///
  /// This method is intentionally forgiving: if the server call fails, local
  /// tokens are still cleared so the user is logged out from the app.
  Future<ApiResult<void>> logout();

  /// Silently refreshes the access token using the stored refresh token.
  ///
  /// Called by [AuthInterceptor] transparently; higher layers should not
  /// need to call this directly.
  Future<ApiResult<AuthTokens>> refreshToken();

  /// Attempts to restore a previously authenticated session from secure storage.
  ///
  /// Returns `null` inside [Success] when no stored session exists.
  /// Returns a [Failure] only on unexpected errors; an expired/missing token
  /// resolves as `Success(null)`.
  Future<ApiResult<AuthSession?>> restoreSession();
}
