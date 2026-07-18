import 'dart:convert';
import 'package:dio/dio.dart';

/// A Mock Interceptor that catches all API requests and returns locally
/// mocked data. This disables network traffic and allows testing the UI
/// entirely offline.
class MockInterceptor extends Interceptor {
  // In-memory simulation of user session
  static Map<String, dynamic>? _currentUser;

  // In-memory simulation of student account database
  static Map<String, dynamic>? _accountData;

  static void _initAccount(String studentId) {
    if (_accountData != null) return;
    _accountData = {
      'student_id': studentId,
      'balance': 120.50,
      'daily_limit': 50.00,
      'today_spent': 15.00,
      'transactions': [
        {
          'id': 'tx_001',
          'description': 'School Cafeteria',
          'amount': 8.50,
          'timestamp': '2026-07-18T10:15:00.000Z',
          'type': 'debit',
        },
        {
          'id': 'tx_002',
          'description': 'Stationery Shop',
          'amount': 6.50,
          'timestamp': '2026-07-18T12:30:00.000Z',
          'type': 'debit',
        },
      ],
    };
  }

  // In-memory simulation of rewards database
  static Map<String, dynamic>? _rewardsData;

  static void _initRewards(String studentId) {
    if (_rewardsData != null) return;
    _rewardsData = {
      'student_id': studentId,
      'total_points': 480,
      'tier': 'silver',
      'streak_days': 7,
      'next_milestone_points': 600,
      'milestones': [
        {'tier': 'bronze', 'min_points': 0, 'max_points': 200},
        {'tier': 'silver', 'min_points': 200, 'max_points': 600},
        {'tier': 'gold', 'min_points': 600, 'max_points': 1200},
        {'tier': 'platinum', 'min_points': 1200},
      ],
      'achievements': [
        {
          'id': 'first_pay',
          'name': 'First Payment',
          'description': 'Completed your very first payment',
          'earned': true,
          'claimed': true,
          'icon': 'payment',
          'points': 50,
        },
        {
          'id': 'saver_5',
          'name': '5-Day Saver',
          'description': 'Stay under budget for 5 days straight',
          'earned': false,
          'icon': 'savings',
          'points': 100,
          'progress': 3,
          'goal': 5,
        },
        {
          'id': 'qr_master',
          'name': 'QR Master',
          'description': 'Used QR scan to pay 10 times',
          'earned': true,
          'claimed': false,
          'icon': 'qr_code_scanner',
          'points': 75,
        },
        {
          'id': 'streak_14',
          'name': '2-Week Warrior',
          'description': 'Keep a 14-day budget streak',
          'earned': false,
          'icon': 'local_fire_department',
          'points': 200,
          'progress': 7,
          'goal': 14,
        },
        {
          'id': 'big_saver',
          'name': 'Big Saver',
          'description': 'Save KSh 1,000 in a month',
          'earned': false,
          'icon': 'account_balance_wallet',
          'points': 150,
          'progress': 480,
          'goal': 1000,
        },
        {
          'id': 'social_star',
          'name': 'Social Star',
          'description': 'Refer a friend to HapoPay',
          'earned': true,
          'claimed': true,
          'icon': 'share',
          'points': 100,
        },
      ],
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;

    // 1. JWT Refresh
    if (path.contains('/accounts/token/refresh/')) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'access': 'mock_new_access_token',
          'refresh': 'mock_new_refresh_token',
        },
      ));
      return;
    }

    // 2. Login
    if (path.contains('/accounts/token/')) {
      final email =
          (options.data as Map?)?['email'] as String? ?? 'student@hapopay.com';
      final isParent = email.toLowerCase().contains('parent');
      _currentUser = {
        'id': isParent ? 'parent_123' : 'student_123',
        'email': email,
        'full_name': isParent ? 'Demo Parent' : 'Demo Student',
        'role': isParent ? 'parent' : 'student',
        'avatar_url': null,
      };
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'access': isParent
              ? 'mock_access_token_parent'
              : 'mock_access_token_student',
          'refresh': 'mock_refresh_token',
          'user': _currentUser,
        },
      ));
      return;
    }

    // 3. Register
    if (path.contains('/accounts/register/')) {
      final email =
          (options.data as Map?)?['email'] as String? ?? 'student@hapopay.com';
      final fullName =
          (options.data as Map?)?['full_name'] as String? ?? 'New User';
      final role = (options.data as Map?)?['role'] as String? ?? 'student';
      _currentUser = {
        'id': 'user_${role}_123',
        'email': email,
        'full_name': fullName,
        'role': role,
        'avatar_url': null,
      };
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'access': 'mock_access_token_$role',
          'refresh': 'mock_refresh_token',
          'user': _currentUser,
        },
      ));
      return;
    }

    // 4. Logout
    if (path.contains('/accounts/logout/')) {
      _currentUser = null;
      _rewardsData = null;
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'detail': 'Successfully logged out.'},
      ));
      return;
    }

    // 5. Get User Profile
    if (path.contains('/accounts/me/')) {
      if (_currentUser == null) {
        final authHeader = options.headers['Authorization'] as String? ?? '';
        final isParent = authHeader.contains('parent');
        _currentUser = {
          'id': isParent ? 'parent_123' : 'student_123',
          'email': isParent ? 'parent@hapopay.com' : 'student@hapopay.com',
          'full_name': isParent ? 'Demo Parent' : 'Demo Student',
          'role': isParent ? 'parent' : 'student',
          'avatar_url': null,
        };
      }
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _currentUser,
      ));
      return;
    }

    // 6. Claim achievement: /rewards/{studentId}/claim/
    if (path.contains('/rewards/') && path.endsWith('/claim/')) {
      final regExp = RegExp(r'/rewards/([^/]+)/claim/');
      final match = regExp.firstMatch(path);
      final studentId = match?.group(1) ?? 'demo';
      _initRewards(studentId);

      final achievementId =
          (options.data as Map?)?['achievement_id'] as String?;
      if (achievementId != null && _rewardsData != null) {
        final achievementsList = _rewardsData!['achievements'] as List<dynamic>;
        for (var i = 0; i < achievementsList.length; i++) {
          final ach = achievementsList[i] as Map<String, dynamic>;
          if (ach['id'] == achievementId) {
            if (ach['earned'] == true && ach['claimed'] == false) {
              ach['claimed'] = true;
              final pts = ach['points'] as int? ?? 0;
              final currentTotal = _rewardsData!['total_points'] as int? ?? 0;
              final newTotal = currentTotal + pts;
              _rewardsData!['total_points'] = newTotal;

              // Re-calculate tier and next milestone points
              if (newTotal >= 1200) {
                _rewardsData!['tier'] = 'platinum';
                _rewardsData!['next_milestone_points'] = null;
              } else if (newTotal >= 600) {
                _rewardsData!['tier'] = 'gold';
                _rewardsData!['next_milestone_points'] = 1200;
              } else if (newTotal >= 200) {
                _rewardsData!['tier'] = 'silver';
                _rewardsData!['next_milestone_points'] = 600;
              } else {
                _rewardsData!['tier'] = 'bronze';
                _rewardsData!['next_milestone_points'] = 200;
              }
            }
            break;
          }
        }
      }

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _rewardsData,
      ));
      return;
    }

    // 7. Get Rewards: /rewards/{studentId}/
    if (path.contains('/rewards/')) {
      final regExp = RegExp(r'/rewards/([^/]+)/');
      final match = regExp.firstMatch(path);
      final studentId = match?.group(1) ?? 'demo';
      _initRewards(studentId);

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _rewardsData,
      ));
      return;
    }

    // 8. Get student account: /student/account/{studentId}/
    if (path.contains('/student/account/')) {
      final regExp = RegExp(r'/student/account/([^/]+)/');
      final match = regExp.firstMatch(path);
      final studentId = match?.group(1) ?? 'student_123';
      _initAccount(studentId);

      if (options.method == 'PATCH') {
        final limit = (options.data as Map?)?['daily_limit'] as double?;
        if (limit != null) {
          _accountData!['daily_limit'] = limit;
        }
      }

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _accountData,
      ));
      return;
    }

    // 9. Process QR payments: /payments/process/
    if (path.contains('/payments/process/')) {
      final studentId =
          (options.data as Map?)?['student_id'] as String? ?? 'student_123';
      _initAccount(studentId);

      final qrPayload = (options.data as Map?)?['qr_payload'] as String? ?? '';

      // Parse QR payload
      Map<String, dynamic> qrData = {};
      try {
        qrData = jsonDecode(qrPayload) as Map<String, dynamic>;
      } catch (_) {
        try {
          qrData = Uri.splitQueryString(qrPayload);
        } catch (e) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'detail': 'Invalid QR payload format.'},
            ),
          ));
          return;
        }
      }

      final amount = double.tryParse(qrData['amount']?.toString() ?? '') ?? 0.0;
      final description =
          qrData['description']?.toString() ?? 'QR Merchant Payment';

      if (amount <= 0) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'detail': 'Payment amount must be greater than zero.'},
          ),
        ));
        return;
      }

      final currentBalance = _accountData!['balance'] as double;
      final dailyLimit = _accountData!['daily_limit'] as double;
      final todaySpent = _accountData!['today_spent'] as double;

      if (amount > currentBalance) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'detail': 'Transaction declined: Insufficient funds.'},
          ),
        ));
        return;
      }

      if (dailyLimit == 0.0) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'detail': 'Transaction declined: Card is locked.'},
          ),
        ));
        return;
      }

      if (todaySpent + amount > dailyLimit) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {
              'detail': 'Transaction declined: Daily spending limit exceeded.'
            },
          ),
        ));
        return;
      }

      // Process payment atomically in the mock ledger
      _accountData!['balance'] = currentBalance - amount;
      _accountData!['today_spent'] = todaySpent + amount;
      final txList = _accountData!['transactions'] as List<dynamic>;
      txList.insert(0, {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'description': description,
        'amount': amount,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'type': 'debit',
      });

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _accountData,
      ));
      return;
    }

    // Default: forward to the actual network client
    handler.next(options);
  }
}
