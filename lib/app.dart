import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapo_pay/core/router/app_router.dart';
import 'package:hapo_pay/core/theme/app_theme.dart';

class HapoPayApp extends ConsumerWidget {
  const HapoPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HapoPay',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
