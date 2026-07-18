import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_service.dart';
import 'local_cache_service.dart';

/// Provides the application-scoped [SecureStorageService].
///
/// Kept alive (non-auto-dispose) so a single storage instance is shared
/// across all features and survives screen navigation.
final tokenStorageProvider = Provider<SecureStorageService>(
  (_) => const SecureStorageService(),
);

/// Provider for SharedPreferences. Must be overridden in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

/// Provides the application-scoped [LocalCacheService].
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalCacheService(prefs);
});
