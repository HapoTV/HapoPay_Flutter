import 'package:dio/dio.dart';
import '../storage/local_cache_service.dart';

/// Interceptor that caches GET responses and serves them when offline.
class CacheInterceptor extends Interceptor {
  CacheInterceptor(this._cacheService);

  final LocalCacheService _cacheService;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET requests
    if (response.requestOptions.method == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = _getCacheKey(response.requestOptions);
      _cacheService.saveCache(key, response.data);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isNetworkError = _isNetworkError(err);
    final isGetRequest = err.requestOptions.method == 'GET';

    if (isNetworkError && isGetRequest) {
      final key = _getCacheKey(err.requestOptions);
      final cachedData = _cacheService.getCache(key);

      if (cachedData != null) {
        // Resolve with cached data, simulating a successful response
        final response = Response(
          requestOptions: err.requestOptions,
          data: cachedData,
          statusCode: 200,
          statusMessage: 'OK (Cached)',
        );
        handler.resolve(response);
        return;
      }
    }

    handler.next(err);
  }

  String _getCacheKey(RequestOptions options) {
    return options.uri.toString();
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown;
  }
}
