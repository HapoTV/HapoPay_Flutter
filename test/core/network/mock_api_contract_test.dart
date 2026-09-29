import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hapopay/core/network/mock_interceptor.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://mock.local',
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    dio.interceptors.add(MockInterceptor());
  });

  test('auth, rewards, account, payments, and parent endpoints', () async {
    final login = await dio.post(
      '/accounts/token/',
      data: {'email': 'student@hapopay.com', 'password': 'secret'},
    );
    expect(login.statusCode, 200);
    expect(login.data['user']['role'], 'student');
    final studentId = login.data['user']['id'] as String;

    final me = await dio.get('/accounts/me/');
    expect(me.data['email'], 'student@hapopay.com');

    final rewards = await dio.get('/rewards/$studentId/');
    expect(rewards.data['tier'], 'silver');
    expect(rewards.data['total_points'], 220);

    final claimed = await dio.post(
      '/rewards/$studentId/claim/',
      data: {'achievement_id': 'qr_rookie'},
    );
    expect(claimed.data['total_points'], 270);

    final account = await dio.get('/student/account/$studentId/');
    expect(account.data['balance'], 120.5);

    final limited = await dio.patch(
      '/student/account/$studentId/',
      data: {'daily_limit': 75},
    );
    expect(limited.data['daily_limit'], 75);

    final paid = await dio.post(
      '/payments/process/',
      data: {
        'student_id': studentId,
        'qr_payload': '{"amount":"4.50","description":"School Cafeteria"}',
      },
    );
    expect(paid.statusCode, 200);
    expect(paid.data['balance'], closeTo(116.0, 0.001));
    expect(paid.data['transactions'][0]['description'], 'School Cafeteria');

    try {
      await dio.post(
        '/payments/process/',
        data: {
          'student_id': studentId,
          'qr_payload': '{"amount":"99999","description":"Too big"}',
        },
      );
      fail('expected the payment to be declined');
    } on DioException catch (error) {
      expect(error.response?.statusCode, 400);
      expect(error.response?.data['detail'], contains('Insufficient funds'));
    }

    final dashboard = await dio.get('/parent/dashboard/');
    expect(dashboard.data['children'], isNotEmpty);
    expect(dashboard.data['family_balance'], 182.7);

    final ledger = await dio.get('/parent/ledger/');
    expect(ledger.data['transactions'], isNotEmpty);

    final refresh = await dio.post(
      '/accounts/token/refresh/',
      data: {'refresh': 'mock_refresh_token'},
    );
    expect(refresh.data['access'], isNotEmpty);

    final registered = await dio.post(
      '/accounts/register/',
      data: {
        'email': 'parent@hapopay.com',
        'password': 'secret',
        'full_name': 'Demo Parent',
        'role': 'parent',
      },
    );
    expect(registered.data['user']['role'], 'parent');

    final logout = await dio.post(
      '/accounts/logout/',
      data: {'refresh': 'mock_refresh_token'},
    );
    expect(logout.statusCode, 200);
  });
}
