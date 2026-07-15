import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'auth_state.dart';

export '../../domain/entities/app_user.dart'; // AppUser, UserRole
export 'auth_notifier.dart' show AuthNotifier;
export 'auth_state.dart'; // AuthState, AuthStatus

/// The primary authentication provider.
///
/// Exposes [AuthState] and [AuthNotifier] to the entire application.
///
/// **Reading state:**
/// ```dart
/// final authState = ref.watch(authProvider);
/// final user      = ref.watch(authProvider.select((s) => s.user));
/// ```
///
/// **Triggering actions:**
/// ```dart
/// ref.read(authProvider.notifier).login(email, password);
/// ref.read(authProvider.notifier).logout();
/// ```
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
