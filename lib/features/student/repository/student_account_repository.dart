import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../models/student_account_model.dart';

part 'student_account_repository.g.dart';

class StudentAccountRepository {
  final Dio _dio;

  StudentAccountRepository(this._dio);

  /// Fetch account details: balance, daily limit, today's spent amount, and transactions.
  Future<StudentAccountModel> fetchAccount(String studentId) async {
    final response = await _dio.get('/student/account/$studentId/');
    return StudentAccountModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Process QR-based payment.
  /// Expects to return the updated [StudentAccountModel] upon success.
  Future<StudentAccountModel> processPayment({
    required String studentId,
    required String qrPayload,
  }) async {
    final response = await _dio.post(
      '/payments/process/',
      data: {
        'student_id': studentId,
        'qr_payload': qrPayload,
      },
    );
    return StudentAccountModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update the spending limit for a student child (used by parent).
  Future<StudentAccountModel> updateSpendingLimit({
    required String studentId,
    required double limit,
  }) async {
    final response = await _dio.patch(
      '/student/account/$studentId/',
      data: {'daily_limit': limit},
    );
    return StudentAccountModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
StudentAccountRepository studentAccountRepository(Ref ref) {
  return StudentAccountRepository(ref.watch(dioProvider));
}
