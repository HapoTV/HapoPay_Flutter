import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Global error interceptor that catches any unhandled DioException
/// and throws a mapped ApiException for UI layers to catch.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapDioError(err);
    // Passing our ApiException wrapped in a DioException so it continues
    // propagating properly but carries the typed error.
    handler.next(
      err.copyWith(
        error: apiException,
        message: apiException.message,
      ),
    );
  }

  ApiException _mapDioError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      switch (statusCode) {
        case 400:
        case 422:
          return ValidationException(
            message: _extractMessage(err.response) ?? 'Validation failed',
            statusCode: statusCode,
          );
        case 401:
          return const UnauthorizedException();
        case 403:
          return const ForbiddenException();
        case 404:
          return const NotFoundException();
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(statusCode: statusCode);
        default:
          return UnknownException(
            message: _extractMessage(err.response) ??
                'An unexpected error occurred.',
          );
      }
    }

    return const UnknownException();
  }

  String? _extractMessage(Response? response) {
    try {
      if (response?.data is Map<String, dynamic>) {
        final data = response!.data as Map<String, dynamic>;
        // Common Django REST Framework error keys
        if (data.containsKey('detail')) return data['detail'] as String;
        if (data.containsKey('message')) return data['message'] as String;
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return null;
  }
}
