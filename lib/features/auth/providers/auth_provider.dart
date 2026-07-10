import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

part 'auth_provider.g.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.token, this.isLoading = false, this.error});

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _loadSession();
    return AuthState();
  }

  Future<void> _loadSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      // In a real app, you might fetch the user profile here
      state = state.copyWith(token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final (user, token) =
          await ref.read(authRepositoryProvider).login(email, password);
      await _storage.write(key: 'jwt_token', value: token);
      state = state.copyWith(user: user, token: token, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    state = AuthState();
  }
}
