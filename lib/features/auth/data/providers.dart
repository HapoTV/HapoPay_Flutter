import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_provider.dart';
import '../domain/repositories/i_auth_repository.dart';
import 'datasources/auth_remote_datasource.dart';
import 'repositories/auth_repository_impl.dart';

/// Provides the [IAuthRepository] implementation.
///
/// Wires [AuthRemoteDataSource] (backed by the app-wide [Dio] instance)
/// with [SecureStorageService] for token persistence.
///
/// Higher layers depend on [IAuthRepository] (the interface), not on this
/// provider directly — allowing straightforward mock injection in tests.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(ref.watch(dioProvider)),
    storage: ref.watch(tokenStorageProvider),
  );
});
