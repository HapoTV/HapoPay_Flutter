import 'dart:async';

import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_event_bus.dart';

/// Dio interceptor responsible for:
///
/// 1. **JWT injection** – attaches `Authorization: Bearer <access>` to every
///    outgoing request that does not already carry one.
/// 2. **Silent token refresh** – on HTTP 401, attempts a single silent
///    refresh via `POST /accounts/token/refresh/`.
/// 3. **Refresh deduplication** – multiple concurrent 401 responses trigger
///    only *one* refresh request; all other callers await the same
///    [Completer] and receive its result.
/// 4. **Transparent retry** – on successful refresh the original request is
///    replayed with the new token.
/// 5. **Force-logout** – when refresh fails, all tokens are cleared and
///    [AuthEvent.forceLogout] is dispatched via [AuthEventBus].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required AuthEventBus eventBus,
    required Dio dio,
  })  : _storage = storage,
        _eventBus = eventBus,
        _dio = dio;

  final SecureStorageService _storage;
  final AuthEventBus _eventBus;

  /// The parent [Dio] instance; used to replay the original request after a
  /// successful refresh (avoiding a second interceptor chain pass for the
  /// refresh call itself).
  final Dio _dio;

  /// Guards concurrent refresh attempts.
  bool _isRefreshing = false;

  /// Shared future for callers that arrive while a refresh is in progress.
  Completer<bool>? _refreshCompleter;

  /// Extra key used to mark a request as already-retried, preventing infinite
  /// 401 loops on legitimately invalid tokens.
  static const _retriedKey = '_auth_retried';

  // ---------------------------------------------------------------------------
  // Interceptor overrides
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshEndpoint = _isRefreshPath(err.requestOptions.path);
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (is401 && !isRefreshEndpoint && !alreadyRetried) {
      final refreshed = await _attemptTokenRefresh();

      if (refreshed) {
        try {
          final opts = err.requestOptions;
          opts.extra[_retriedKey] = true;
          final newToken = await _storage.getAccessToken();
          opts.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch<dynamic>(opts);
          handler.resolve(response);
          return;
        } on DioException catch (retryErr) {
          handler.next(retryErr);
          return;
        }
      }
      // Refresh failed; force-logout was already dispatched inside
      // _attemptTokenRefresh. Just pass the error through.
    }

    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Refresh deduplication
  // ---------------------------------------------------------------------------

  /// Coordinates a token refresh even when multiple requests 401
  /// simultaneously.
  ///
  /// The *first* caller sets [_isRefreshing] and creates the [Completer].
  /// Every subsequent concurrent caller awaits the same completer's future,
  /// ensuring only **one** `POST /accounts/token/refresh/` is sent.
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      // Another refresh is already in flight – wait for its result.
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw StateError('No refresh token in secure storage.');
      }

      // Use a clean Dio instance to avoid re-triggering this interceptor.
      final refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl));
      final response = await refreshDio.post(
        '/accounts/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String;
      final newRefresh = (response.data['refresh'] as String?) ?? refreshToken;

      await _storage.saveTokens(access: newAccess, refresh: newRefresh);

      completer.complete(true);
      return true;
    } catch (_) {
      await _storage.clearTokens();
      _eventBus.dispatch(AuthEvent.forceLogout);
      completer.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  bool _isRefreshPath(String path) => path.contains('/accounts/token/refresh/');
}
