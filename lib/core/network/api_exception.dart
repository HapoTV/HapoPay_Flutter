/// Typed exception hierarchy for all API-layer errors.
///
/// All exceptions carry a [message] that is safe to display to users.
/// The optional [statusCode] is present for HTTP-specific errors.
sealed class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  /// A user-safe, localised-ready error description.
  final String message;

  /// The HTTP status code, if this exception originated from a server response.
  final int? statusCode;

  @override
  String toString() => '$runtimeType(${statusCode ?? 'no-status'}): $message';
}

/// The device has no internet or the server is unreachable.
final class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// The server failed to respond within the configured timeout.
final class RequestTimeoutException extends ApiException {
  const RequestTimeoutException({
    super.message = 'The request timed out. Please try again.',
  });
}

/// The access token is missing, invalid, or expired (HTTP 401).
final class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please log in again.',
    super.statusCode = 401,
  });
}

/// The user does not have permission to access this resource (HTTP 403).
final class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// The requested resource was not found (HTTP 404).
final class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

/// The request data failed server-side validation (HTTP 400 / 422).
final class ValidationException extends ApiException {
  const ValidationException({required super.message, super.statusCode = 400});
}

/// An internal server error occurred (HTTP 5xx).
final class ServerException extends ApiException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.statusCode,
  });
}

/// An unexpected or unclassified error that does not map to a specific case.
final class UnknownException extends ApiException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
  });
}
