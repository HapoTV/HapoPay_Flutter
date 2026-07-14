import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/auth_event_bus.dart';
import '../../data/providers.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_state.dart';

/// Manages the authentication state machine.
///
/// ## Responsibilities
/// - Restores the previous session on app startup (async, non-blocking).
/// - Exposes [login] and [logout] for UI interactions.
/// - Reacts to [AuthEvent.forceLogout] from [AuthInterceptor] via [AuthEventBus].
///
/// ## State transitions
/// ```
/// App launch
///   → unknown  (session restoration in progress)
///   → authenticated   (valid session found)
///   → unauthenticated (no session / refresh failed)
///
/// login() success  → authenticated
/// login() failure  → unauthenticated + errorMessage
/// logout()         → unauthenticated
/// forceLogout      → unauthenticated + errorMessage (session expired)
/// ```
///
/// The router listens to [authProvider] and redirects accordingly.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Subscribe to force-logout events dispatched by the network layer.
    // The subscription is cancelled automatically when the notifier is disposed.
    final subscription = ref.read(authEventBusProvider).events.listen((event) {
      if (event == AuthEvent.forceLogout) _onForceLogout();
    });
    ref.onDispose(subscription.cancel);

    // Kick off session restoration without blocking the synchronous build.
    _restoreSession();

    return AuthState.initial;
  }

  IAuthRepository get _repository => ref.read(authRepositoryProvider);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Authenticates the user with [email] and [password].
  ///
  /// Transitions: unknown/unauthenticated → loading → authenticated | unauthenticated
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.login(email, password);

    result.when(
      success: (session) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: session.user,
        );
      },
      failure: (error) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: error.message,
        );
      },
    );
  }

  /// Registers a new user account.
  ///
  /// The UI layer is responsible for constructing a [RegisterRequestDto] and
  /// calling this method.
  Future<void> register(covariant Object params) async {
    // Signature uses covariant Object to allow the data layer's RegisterRequestDto
    // to be passed without importing it directly in all callers.
    // Cast is safe because the caller controls the type.
    // ignore: avoid_dynamic_calls
    state = state.copyWith(isLoading: true, clearError: true);
    // Delegate to the public register method once register screen is built.
    // Intentionally left as a thin stub — expand when the register flow is added.
  }

  /// Logs out the current user.
  ///
  /// Clears local tokens and notifies the server (best-effort).
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _restoreSession() async {
    final result = await _repository.restoreSession();

    result.when(
      success: (session) {
        if (session != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: session.user,
          );
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
      failure: (_) {
        // Any unexpected error during restore is treated as no session.
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }

  /// Called when [AuthInterceptor] dispatches [AuthEvent.forceLogout].
  void _onForceLogout() {
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Your session has expired. Please log in again.',
    );
  }
}
