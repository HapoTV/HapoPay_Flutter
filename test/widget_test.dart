import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hapopay/core/network/api_exception.dart';
import 'package:hapopay/core/network/dio_client.dart';
import 'package:hapopay/core/storage/storage_provider.dart';
import 'package:hapopay/core/storage/local_cache_service.dart';
import 'package:hapopay/core/network/cache_interceptor.dart';
import 'package:hapopay/core/network/retry_interceptor.dart';
import 'package:hapopay/core/network/error_interceptor.dart';

// --- The Manual Test Screen ---
class TestResilienceScreen extends ConsumerStatefulWidget {
  const TestResilienceScreen({super.key});

  @override
  ConsumerState<TestResilienceScreen> createState() => _TestResilienceScreenState();
}

class _TestResilienceScreenState extends ConsumerState<TestResilienceScreen> {
  String _result = 'Press the button to test network...';
  bool _isLoading = false;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _result = 'Fetching...';
    });

    try {
      final dio = ref.read(dioProvider);
      
      // Using a public JSON API to test GET caching
      final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');
      
      setState(() {
        _result = 'SUCCESS!\nStatus: ${response.statusCode}\nData: ${response.data}';
      });
    } on DioException catch (e) {
      setState(() {
        if (e.error is ApiException) {
          final apiError = e.error as ApiException;
          _result = 'API EXCEPTION:\n${apiError.message}';
        } else {
          _result = 'DIO EXCEPTION:\n${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'UNKNOWN ERROR:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Resilience Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Test Steps...'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              height: 200,
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  key: const Key('result_text'),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchData,
              child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Fetch Data (GET)'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- The Widget Test ---
class MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) callback;

  MockAdapter(this.callback);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    return callback(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TestResilienceScreen handles offline caching manually', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create a local Dio instance that mimics the resilience pipeline
    // but skips AuthInterceptor to avoid flutter_secure_storage MissingPluginExceptions in tests.
    final testDio = Dio();
    testDio.interceptors.addAll([
      CacheInterceptor(LocalCacheService(prefs)),
      RetryInterceptor(dio: testDio, maxRetries: 1),
      ErrorInterceptor(),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dioProvider.overrideWithValue(testDio),
        ],
        child: const MaterialApp(
          home: TestResilienceScreen(),
        ),
      ),
    );

    // Initial State
    expect(find.text('Press the button to test network...'), findsOneWidget);

    // We can inject a mock adapter to the dio instance inside the test if needed.
    final context = tester.element(find.byType(TestResilienceScreen));
    final dio = ProviderScope.containerOf(context).read(dioProvider);

    // Mock a successful response
    dio.httpClientAdapter = MockAdapter((options) async {
      return ResponseBody.fromString('{"data": "cached_todo"}', 200, headers: {
        Headers.contentTypeHeader: ['application/json'],
      });
    });

    // Tap to fetch
    await tester.tap(find.text('Fetch Data (GET)'));
    await tester.pump(); // Start the fetch
    await tester.pump(const Duration(seconds: 1)); // Wait for future

    // Verify UI updated with cached data
    expect(find.textContaining('SUCCESS!'), findsOneWidget);
    expect(find.textContaining('cached_todo'), findsOneWidget);

    // Now mock an offline failure
    dio.httpClientAdapter = MockAdapter((options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });

    // Tap to fetch again (offline)
    await tester.tap(find.text('Fetch Data (GET)'));
    await tester.pump(); // Start the fetch
    await tester.pump(const Duration(seconds: 1)); // Wait for future

    // Should STILL show SUCCESS because it fetched from CacheInterceptor!
    expect(find.textContaining('SUCCESS!'), findsOneWidget);
    expect(find.textContaining('cached_todo'), findsOneWidget);
  });
}

