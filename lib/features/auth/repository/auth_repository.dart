import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<(UserModel, dynamic)> login(String email, String password) async {
    final response = await _dio.post(
      '/token/',
      data: {'email': email, 'password': password},
    );

    final user = UserModel.fromJson(response.data['user']);
    final token = response.data['access'];

    return (user, token);
  }

  Future<void> logout() async {
    // In a real app, you might notify the backend or just clear local storage
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioProvider));
}
