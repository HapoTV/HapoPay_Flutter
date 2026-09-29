import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hapopay/core/network/mock_interceptor.dart';

/// Serves [MockInterceptor] over HTTP so Postman and curl can exercise the
/// same contract the Flutter app uses when `USE_MOCK_API=true`.
///
/// ```bash
/// dart run tool/mock_api_server.dart
/// ```
///
/// Listens on `127.0.0.1:8000` unless `PORT` is set.
Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8000;
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://mock.local',
      validateStatus: (status) => status != null && status < 500,
    ),
  );
  dio.interceptors.add(MockInterceptor());

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('HapoPay mock API listening on http://127.0.0.1:$port/api');

  await for (final request in server) {
    try {
      final bytes = await request.fold<List<int>>(<int>[], (previous, chunk) {
        previous.addAll(chunk);
        return previous;
      });
      Object? data;
      if (bytes.isNotEmpty) {
        data = jsonDecode(utf8.decode(bytes));
      }

      var path = request.uri.path;
      if (path.startsWith('/api')) {
        path = path.substring(4);
        if (path.isEmpty) path = '/';
      }

      final response = await dio.request<dynamic>(
        path,
        data: data,
        options: Options(
          method: request.method,
          headers: {
            if (request.headers.value(HttpHeaders.authorizationHeader) != null)
              'Authorization': request.headers.value(
                HttpHeaders.authorizationHeader,
              ),
          },
          contentType: Headers.jsonContentType,
        ),
      );

      request.response.statusCode = response.statusCode ?? 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response.data));
    } on DioException catch (error) {
      request.response.statusCode = error.response?.statusCode ?? 500;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode(error.response?.data ?? {'detail': error.message}),
      );
    } catch (error) {
      request.response.statusCode = 500;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'detail': '$error'}));
    }
    await request.response.close();
  }
}
