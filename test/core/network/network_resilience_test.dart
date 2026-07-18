import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:hapopay/core/network/error_interceptor.dart';
import 'package:hapopay/core/network/api_exception.dart';
import 'package:hapopay/core/network/retry_interceptor.dart';
import 'package:hapopay/core/network/cache_interceptor.dart';
import 'package:hapopay/core/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAdapter implements HttpClientAdapter {
  int attempts = 0;
  final Future<ResponseBody> Function(RequestOptions options, int attempt) callback;

  MockAdapter(this.callback);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    attempts++;
    return callback(options, attempts);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ErrorInterceptor Tests', () {
    test('Should map DioExceptionType.connectionTimeout to NetworkException', () async {
      final dio = Dio();
      dio.interceptors.add(ErrorInterceptor());
      dio.httpClientAdapter = MockAdapter((options, attempt) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });

      try {
        await dio.get('https://example.com');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.error, isA<NetworkException>());
        expect((e.error as NetworkException).message, contains('internet connection'));
      }
    });

    test('Should map 401 to UnauthorizedException', () async {
      final dio = Dio();
      dio.interceptors.add(ErrorInterceptor());
      dio.httpClientAdapter = MockAdapter((options, attempt) async {
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
          ),
        );
      });

      try {
        await dio.get('https://example.com');
        fail('Should have thrown');
      } on DioException catch (e) {
        expect(e.error, isA<UnauthorizedException>());
      }
    });
  });

  group('RetryInterceptor Tests', () {
    test('Should retry up to maxRetries on connection error', () async {
      final dio = Dio();
      // Use maxRetries: 2 so the test doesn't take too long (1s + 2s = 3s total wait)
      dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 2));
      
      final adapter = MockAdapter((options, attempt) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });
      dio.httpClientAdapter = adapter;

      try {
        await dio.get('https://example.com');
      } catch (_) {}

      expect(adapter.attempts, 3); // 1 initial + 2 retries
    });
  });

  group('CacheInterceptor Tests', () {
    test('Should fallback to cache on network error', () async {
      final prefs = await SharedPreferences.getInstance();
      final cacheService = LocalCacheService(prefs);
      
      final dio = Dio();
      dio.interceptors.add(CacheInterceptor(cacheService));
      
      // Simulate success first to populate cache
      dio.httpClientAdapter = MockAdapter((options, attempt) async {
        return ResponseBody.fromString('{"data": "cached"}', 200, headers: {
          Headers.contentTypeHeader: ['application/json'],
        });
      });
      await dio.get('https://example.com');
      
      // Now simulate offline
      dio.httpClientAdapter = MockAdapter((options, attempt) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });
      
      final response = await dio.get('https://example.com');
      expect(response.statusCode, 200);
      expect(response.data, equals({'data': 'cached'}));
    });
  });
}
