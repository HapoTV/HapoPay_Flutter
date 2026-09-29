import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hapopay/features/qrcode/presentation/screens/pin_authentication.dart';

import '../../features/auth/presentation/Login/login_screen.dart';
import '../../features/auth/presentation/Registration/register_screen.dart';
import '../../features/splash_screen/presentation/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/parent/presentation/screens/family_ledger_screen.dart';
import '../../features/parent/presentation/screens/spending_limits_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/student/presentation/screens/rewards_screen.dart';
import '../../features/qrcode/presentation/qrcode.dart';
import '../../shared/widgets/main_app_scaffold.dart';

// ---------------------------------------------------------------------------
// Internal refresh notifier
// ---------------------------------------------------------------------------

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // -----------------------------------------------------------------------
      // Auth Redirection Logic (Commented out for UI review & testing)
      // -----------------------------------------------------------------------
      // final authState = ref.read(authProvider);
      // final location = state.matchedLocation;
      //
      // // When on splash screen, let the splash animation finish
      // if (location == '/splash') return null;
      //
      // // If user is not authenticated and not on an auth screen, allow login/register
      // if (!authState.isAuthenticated) {
      //   if (location == '/login' || location == '/register') {
      //     return null;
      //   }
      //   return null;
      // }
      //
      // // If authenticated and on login / register, redirect to appropriate role dashboard
      // if (location == '/login' || location == '/register') {
      //   return authState.user?.isParent == true ? '/parent' : '/student';
      // }

      return null;
    },
    routes: [
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const SplashScreen(),
      // ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) =>
            const MainAppScaffold(initialRole: UserRole.parent),
        routes: [
          GoRoute(
            path: 'ledger',
            builder: (context, state) => const FamilyLedgerScreen(),
          ),
          GoRoute(
            path: 'limits',
            builder: (context, state) => const SpendingLimitsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) =>
            const MainAppScaffold(initialRole: UserRole.student),
        routes: [
          GoRoute(
            path: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: 'pay-qr',
            builder: (context, state) => const PayQrScreen(),
            routes: [
              GoRoute(
                path: 'pin-auth',
                builder: (context, state) => PinAuthentication(),
              ),
            ],
          ),
          GoRoute(
            path: 'my-qr',
            builder: (context, state) => const MyQrScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
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
