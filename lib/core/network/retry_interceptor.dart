import 'dart:async';
import 'package:dio/dio.dart';

/// Interceptor that retries failed requests due to intermittent network conditions.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  final Dio dio;
  final int maxRetries;

  static const String _retryCountKey = '_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra[_retryCountKey] as int? ?? 0;

      if (retryCount < maxRetries) {
        // Wait before retrying (Exponential backoff)
        final delaySeconds = 1 << retryCount; // 1s, 2s, 4s...
        await Future.delayed(Duration(seconds: delaySeconds));

        try {
          final options = err.requestOptions;
          options.extra[_retryCountKey] = retryCount + 1;

          // Re-issue the request
          final response = await dio.fetch<dynamic>(options);
          handler.resolve(response);
          return;
        } on DioException catch (retryErr) {
          // Pass the new error down to potentially hit this interceptor again
          handler.next(retryErr);
          return;
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network/connection timeouts and errors
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}
