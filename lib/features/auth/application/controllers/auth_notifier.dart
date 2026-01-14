import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../state/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage; 

  AuthNotifier(this.repository, this.storage) : super(AuthState.initial());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await repository.login(username: username, password: password);
      
      state = state.copyWith(
        isLoading: false,
        token: response.accessToken,
        user: response.user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.checkAuthStatus();
      
      state = state.copyWith(
        isLoading: false,
        token: response.accessToken,
        user: response.user,
      );
    } catch (e) {
      state = AuthState.initial();
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = AuthState.initial();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String username,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repository.register(
        name: name,
        email: email,
        password: password,
        username: username,
        userType: userType,
      );

      state = state.copyWith(isLoading: false);

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}