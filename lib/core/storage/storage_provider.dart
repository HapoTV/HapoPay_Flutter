import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';

/// Provides the application-scoped [SecureStorageService].
///
/// Kept alive (non-auto-dispose) so a single storage instance is shared
/// across all features and survives screen navigation.
final tokenStorageProvider = Provider<SecureStorageService>(
  (_) => const SecureStorageService(),
);
