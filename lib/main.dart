import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (EnvConfig.supabaseUrl.isNotEmpty &&
        EnvConfig.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        publishableKey: EnvConfig.supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: HapoPayApp(),
    ),
  );
}

class HapoPayApp extends ConsumerWidget {
  const HapoPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HapoPay',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
