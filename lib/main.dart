import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/storage/storage_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.assertReleaseSafe();

  // Supabase is reserved for future OAuth / social-login integration.
  // Initialization is skipped when no URL is configured so the app works
  // fully with JWT auth without requiring a Supabase project.
  if (EnvConfig.supabaseUrl.isNotEmpty) {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  final release = '${packageInfo.version}+${packageInfo.buildNumber}';

  Future<void> startApp() async {
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const HapoPayApp(),
      ),
    );
  }

  if (EnvConfig.sentryDsn.isEmpty) {
    await startApp();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.release = 'hapopay@$release';
      options.environment = kReleaseMode ? 'production' : 'development';
      options.sendDefaultPii = false;
    },
    appRunner: startApp,
  );
}
