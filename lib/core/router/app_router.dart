import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/parent/presentation/parent_dashboard_screen.dart';
import '../../features/student/presentation/student_dashboard_screen.dart';
import '../../features/student/presentation/rewards_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/user_model.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.token == null) {
        return '/login';
      }

      if (isLoggingIn) {
        if (authState.user?.role == UserRole.parent) {
          return '/parent';
        }
        return '/student';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
}
