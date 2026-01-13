import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../state/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage; 

  AuthNotifier(this.repository, this.storage) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await repository.login(email: email, password: password);
      
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
    state = state.copyWith(isLoading: true); // Opcional: mostrar carga inicial
    try {
      final response = await repository.checkAuthStatus();
      
      state = state.copyWith(
        isLoading: false,
        token: response.accessToken,
        user: response.user,
      );
    } catch (e) {
      // Si falla, volvemos a estado inicial (Logout)
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
    required String username, // <--- Nuevo parámetro agregado
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Pasamos el username al repositorio
      await repository.register(
        name: name,
        email: email,
        password: password,
        username: username,
      );

      // ÉXITO:
      // El endpoint de registro devuelve el usuario creado pero NO un token.
      // Por eso, solo ponemos isLoading en false. 
      // La redirección al Login la maneja la UI (RegisterForm) al detectar que no hubo error.
      state = state.copyWith(isLoading: false);

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      // Importante: Rethrow permite que el formulario capture el error y muestre el SnackBar rojo
      rethrow;
    }
  }
}