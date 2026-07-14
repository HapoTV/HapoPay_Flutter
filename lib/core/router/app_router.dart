import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/parent/presentation/parent_dashboard_screen.dart';
import '../../features/student/presentation/rewards_screen.dart';
import '../../features/student/presentation/student_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Internal refresh notifier
// ---------------------------------------------------------------------------

/// Bridges Riverpod auth state changes to [GoRouter]'s [refreshListenable].
///
/// When [AuthState] changes, [notifyListeners] is called, triggering
/// GoRouter to re-evaluate the [redirect] function without recreating
/// the [GoRouter] instance.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref<GoRouter> ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Application-scoped [GoRouter] provider.
///
/// The router is created once and kept alive; navigation state is preserved
/// across auth transitions. Auth-driven redirects are handled by
/// [_RouterRefreshNotifier] + the [redirect] callback.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Read (not watch) avoids re-creating the GoRouter on every state change;
      // re-evaluation is triggered by refreshNotifier instead.
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Still restoring session — do not redirect yet.
      if (authState.isUnknown) return null;

      if (!authState.isAuthenticated) {
        return location == '/login' ? null : '/login';
      }

      // Authenticated: redirect away from login.
      if (location == '/login') {
        return authState.user?.isParent == true ? '/parent' : '/student';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    refreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
