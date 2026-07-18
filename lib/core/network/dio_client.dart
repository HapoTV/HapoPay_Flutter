import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_provider.dart';
import 'auth_event_bus.dart';
import 'auth_interceptor.dart';
import 'mock_interceptor.dart';

/// The single entry point for all API communication.
///
/// Wraps a fully configured [Dio] instance with:
/// - Base URL and timeout settings from [EnvConfig]
/// - [AuthInterceptor] for JWT injection and silent token refresh
/// - [LogInterceptor] in debug builds only (tokens are never logged)
///
/// Consume the configured [Dio] instance through [dioProvider] in
/// repositories.
class DioClient {
  DioClient._(this.dio);

  /// The fully configured [Dio] instance.
  final Dio dio;

  factory DioClient.create({
    required SecureStorageService storage,
    required AuthEventBus eventBus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      MockInterceptor(),
      AuthInterceptor(storage: storage, eventBus: eventBus, dio: dio),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          // Never print Authorization headers; masked at the header level.
          requestHeader: false,
          logPrint: (object) => debugPrint(object.toString()),
        ),
    ]);

    return DioClient._(dio);
  }
}

/// Application-scoped [DioClient] provider.
///
/// Kept alive (non-auto-dispose) so a single HTTP client is reused across
/// all features for the lifetime of the app.
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final eventBus = ref.watch(authEventBusProvider);
  return DioClient.create(storage: storage, eventBus: eventBus);
});

/// Convenience provider exposing the raw [Dio] instance from [dioClientProvider].
///
/// Repositories that only need [Dio] (not the full [DioClient]) should watch
/// this provider.
final dioProvider = Provider<Dio>(
  (ref) => ref.watch(dioClientProvider).dio,
);
