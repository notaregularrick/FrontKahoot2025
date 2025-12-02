import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../../../../core/providers/secure_storage_provider.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
//import '../../domain/entities/user_entity.dart';
import '../../application/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  //final Ref ref;, this.ref
  final SecureStorageService storage;

  AuthNotifier(this.repository, this.storage) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final token = await repository.login(email: email, password: password);

      // Guardar token
      //final storage = ref.read(secureStorageProvider);
      await storage.saveToken(token.accessToken);

      
      state = state.copyWith(
        isLoading: false,
        token: token.accessToken,
        user: token.user.toEntity(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void restoreSession(String token) {
  state = state.copyWith(
    token: token,
    isLoading: false,
  );
  }

  Future<void> logout() async {
    try {
      await repository.logout();

      await storage.deleteToken();

      // Reiniciar estado
      state = state.copyWith(token: null, user: null);

    } catch (e) {
      await storage.deleteToken();
      state = AuthState.initial();
    }
  }
}
