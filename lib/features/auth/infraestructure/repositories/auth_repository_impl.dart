import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

// IMPORTA TU BASE DE DATOS SIMULADA
import '../../../../core/simulated_data.dart'; 

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;
  final ApiService apiService;
  final SecureStorageService storage;

  AuthRepositoryImpl(this.datasource, this.apiService, this.storage);

  @override
  Future<UserEntity?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 800));

      // 1. GUARDAMOS EN LA DB COMPARTIDA
      dbUser = UserModel(
        id: "user-id-123",
        name: name,     // <--- Usamos el nombre del form
        email: email,   // <--- Usamos el email del form
        userType: 'default',
        createdAt: DateTime.now(),
      );

      dbProfile = ProfileModel(
        id: "user-id-123",
        name: name,     // <--- ¡IMPORTANTE! Guardamos lo mismo aquí
        email: email,
        avatarUrl: "",
        description: "Hola, soy nuevo aquí",
        userType: "Básico",
        gameStreak: 0,
        theme: "Día",
        language: "Español",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dbToken = "fake-token-xyz";
      await storage.saveToken(dbToken);

      return dbUser?.toEntity();
    }

    // Lógica real...
    final userModel = await datasource.register(name: name, email: email, password: password);
    return userModel.toEntity();
  }

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. VALIDAMOS CONTRA LA DB COMPARTIDA
      if (dbUser == null) {
        throw Exception("Usuario no encontrado. Debes registrarte primero.");
      }
      if (dbUser!.email != email) {
        throw Exception("Credenciales incorrectas.");
      }

      dbToken = "fake-token-xyz";
      await storage.saveToken(dbToken);

      return AuthResponseModel(
        user: dbUser!,
        accessToken: dbToken!,
      );
    }
    
    // Lógica real...
    final response = await datasource.login(email: email, password: password);
    await storage.saveToken(response.accessToken);
    return response;
  }
  @override
  Future<void> logout() async {
    const simulate = true;
    if (simulate) {
      dbToken = null;
      await storage.deleteToken();
      return;
    }
    await apiService.post('/auth/logout');
    await storage.deleteToken(); // Asegurar borrado local
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    const simulate = true;
    if (simulate) {
      await Future.delayed(const Duration(seconds: 1));
      if (!email.contains('@')) throw Exception("Email inválido");
      return;
    }
    // ... tu lógica real (estaba bien) ...
    try {
      await apiService.post('/auth/password-reset/request', data: {'email': email});
    } catch (e) {
      throw Exception('Error al solicitar reset: $e');
    }
  }

  @override
  Future<void> confirmPasswordReset(String resetToken, String newPassword) async {
    const simulate = true;

    if (simulate) {
      // 1. Simular retraso de red (1.5 segundos)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 2. Simular Validaciones (Opcional, para probar errores en tu UI)
      
      // Simular error si el token está vacío o es un token específico de prueba "bad"
      if (resetToken.isEmpty || resetToken == "invalid-token") {
        throw Exception("El token es inválido o ha expirado.");
      }

      // Simular validación de contraseña corta
      if (newPassword.length < 6) {
        throw Exception("La contraseña debe tener al menos 6 caracteres.");
      }

      // 3. Éxito
      // En una DB real aquí se actualizaría el hash del password.
      // En simulación, simplemente retornamos (void) indicando que todo salió bien.
      print("SIMULACIÓN: Contraseña restablecida exitosamente. Nueva pass: $newPassword");
      return;
    }

    // --- LÓGICA REAL ---
    try {
      await apiService.post('/auth/password-reset/confirm', data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } catch (e) {
      // Es buena práctica atrapar el error de red y lanzar una Exception limpia
      throw Exception('Error al confirmar cambio de contraseña: $e');
    }
  }

 /* @override
  Future<ProfileModel> getUserProfile() async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (dbProfile == null) {
        // Fallback por si acaso
        return ProfileModel(
            id: "temp", 
            name: "Usuario Simulado", 
            email: "test@test.com", 
            avatarUrl: "", 
            description: "Sin descripción", 
            userType: "Guest", 
            gameStreak: 0, 
            theme: "Día", 
            language: "ES", 
            createdAt: DateTime.now(), 
            updatedAt: DateTime.now()
        );
      }
      return dbProfile!;
    }

    try {
      final response = await apiService.get('/profile');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }*/
}