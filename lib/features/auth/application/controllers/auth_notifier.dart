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
        user: response.user, // Asegúrate que UserModel extienda UserEntity
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
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Llamamos al repositorio.
      // En tu simulación, esto crea el usuario Y guarda el token en el Storage.
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
      );

      // 2. CORRECCIÓN CLAVE: Recuperar el token guardado.
      // Como tu repo.register solo devuelve User, necesitamos leer el token 
      // del storage manualmente para actualizar el estado.
      final savedToken = await storage.getToken(); // <--- ESTO FALTABA

      if (savedToken == null) {
        throw Exception("El registro fue exitoso pero no se generó el token.");
      }

      // 3. Actualizamos el estado con AMBOS: usuario y token
      state = state.copyWith(
        isLoading: false,
        user: user,
        token: savedToken, // <--- Ahora la app sabe que estás logueado
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      // Importante: Rethrow para que tu formulario muestre el SnackBar rojo
      rethrow; 
    }
  }
}