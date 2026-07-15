import '../../domain/entities/app_user.dart';

/// The possible lifecycle states of the authentication flow.
enum AuthStatus {
  /// Initial state before session restoration has completed.
  unknown,

  /// A valid session exists; [AuthState.user] is non-null.
  authenticated,

  /// No valid session exists; the user must log in.
  unauthenticated,
}

/// Immutable state for the authentication state machine.
///
/// Produced by [AuthNotifier] and consumed by:
/// - The router (navigation decisions)
/// - Screens (UI rendering and error display)
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// The current phase of the auth lifecycle.
  final AuthStatus status;

  /// The authenticated user; non-null only when [status] is
  /// [AuthStatus.authenticated].
  final AppUser? user;

  /// A user-safe error message set after a failed auth operation.
  final String? errorMessage;

  /// `true` while an async auth operation (login, logout, restore) is
  /// in progress.
  final bool isLoading;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  /// Canonical initial state — shown during session restoration.
  static const initial = AuthState(status: AuthStatus.unknown);

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(status, user, errorMessage, isLoading);

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, isLoading: $isLoading, '
      'error: $errorMessage)';
}
