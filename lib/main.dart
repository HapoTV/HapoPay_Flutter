import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hapo_pay/app.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var logger = Logger();

  try {
    if (EnvConfig.supabaseUrl.isNotEmpty &&
        EnvConfig.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    }
  } catch (e) {
    logger.e('Supabase initialization failed: $e');
  }

  runApp(const ProviderScope(child: HapoPayApp()));
}
