import 'app_user.dart';
import 'auth_tokens.dart';

/// An authenticated session combining user identity with a token pair.
class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  /// The authenticated user.
  final AppUser user;

  /// The access/refresh token pair for this session.
  final AuthTokens tokens;
}
