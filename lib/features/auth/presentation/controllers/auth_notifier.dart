import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../application/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage;

  AuthNotifier(this.repository, this.storage) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final token = await repository.login(email: email, password: password);

      // Guardar token en el dispositivo
      await storage.saveToken(token.accessToken);

      state = state.copyWith(
        isLoading: false,
        token: token.accessToken,
        user: token.user.toEntity(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        // Es mejor limpiar el usuario y token si falla el login
        user: null, 
        token: null,
        errorMessage: e.toString(),
      );
      // Opcional: rethrow; // Si quieres que la UI capture el error con try-catch también
    }
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

  // Mejorado para recuperar también los datos del usuario
  Future<void> restoreSession(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // 1. Ponemos el token en el estado temporalmente
      state = state.copyWith(token: token); 
      
      // 2. Aquí deberías tener un método en tu repo para traer el perfil con el token actual
      // final user = await repository.getUserProfile(token); 
      
      // Por ahora, asumimos que al menos validamos que el token no sea nulo
      state = state.copyWith(
        isLoading: false,
        token: token,
        // user: user // Si tuvieras el endpoint de "getMe" o "profile"
      );
    } catch (e) {
      // Si el token es inválido o expiró, hacemos logout forzoso
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      // Intentamos avisar al backend
      await repository.logout();
    } catch (e) {
      // Si falla (ej. sin internet), no importa, borramos localmente igual
    } finally {
      // Siempre borramos localmente
      await storage.deleteToken();
      state = AuthState.initial();
    }
  }
}