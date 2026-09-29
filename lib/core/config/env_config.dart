import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  /// When true, Dio mounts [MockInterceptor] for offline UI demos.
  /// Must be false for release / production builds.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  /// Optional Sentry DSN. Empty skips crash reporting init.
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Throws in release if mock API or localhost API slipped into the build.
  static void assertReleaseSafe() {
    if (!kReleaseMode) return;

    if (useMockApi) {
      throw StateError(
        'USE_MOCK_API=true is forbidden in release builds. '
        'Use --dart-define-from-file=.env.prod with USE_MOCK_API=false.',
      );
    }

    final host = Uri.tryParse(apiBaseUrl)?.host.toLowerCase() ?? '';
    if (host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.endsWith('.local')) {
      throw StateError(
        'API_BASE_URL="$apiBaseUrl" looks like a local/dev host. '
        'Release builds must point at the production Django API.',
      );
    }
  }
}
