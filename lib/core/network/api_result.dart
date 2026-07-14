import 'api_exception.dart';

/// A discriminated union representing either a successful [T] value or an
/// [ApiException].
///
/// Use the exhaustive [when] to handle both cases:
/// ```dart
/// final result = await repository.login(email, password);
/// result.when(
///   success: (session) => print('Welcome ${session.user.fullName}'),
///   failure: (error)   => showSnackBar(error.message),
/// );
/// ```
sealed class ApiResult<T> {
  const ApiResult();

  /// Exhaustive handler returning a value of type [R].
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  });

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

/// Represents a successfully completed operation with a [data] payload.
final class Success<T> extends ApiResult<T> {
  const Success(this.data);

  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) =>
      success(data);
}

/// Represents a failed operation carrying an [ApiException].
final class Failure<T> extends ApiResult<T> {
  const Failure(this.error);

  final ApiException error;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) =>
      failure(error);
}
