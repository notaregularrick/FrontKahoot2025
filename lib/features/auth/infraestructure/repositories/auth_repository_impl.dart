import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

      // 1. Crear el modelo de perfil
      final newProfile = ProfileModel(
        id: email, // Usamos el email como ID
        name: name,
        email: email,
        avatarUrl: "",
        description: "Nuevo usuario",
        userType: "Básico",
        gameStreak: 0,
        theme: "Día",
        language: "Español",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      
      // 2. Guardar los datos del usuario en su caja específica
      String profileJson = jsonEncode(newProfile.toJson());
      await prefs.setString('profile_$email', profileJson);

      // 3. ¡¡CRÍTICO!! GUARDAR QUE ESTE ES EL USUARIO ACTIVO
      // Sin esta línea, el ProfileRepository no sabe qué caja buscar.
      await prefs.setString('current_active_email', email); 

      // 4. Guardar token (para la sesión)
      await storage.saveToken("fake-token-$email");

      // 5. Retornar UserEntity para que el Notifier actualice el estado
      return UserModel(
        id: newProfile.id,
        name: newProfile.name,
        email: newProfile.email,
        userType: newProfile.userType,
        createdAt: newProfile.createdAt,
      ).toEntity();
    }

    final userModel = await datasource.register(name: name, email: email, password: password);
    return userModel.toEntity();
  }

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    const simulate = true;
    if (simulate) {
       await Future.delayed(const Duration(milliseconds: 800));
       
       final prefs = await SharedPreferences.getInstance();

       // 1. VERIFICAMOS SI EXISTE LA CAJA DE ESE EMAIL
       final userJson = prefs.getString('profile_$email');
       
       if (userJson == null) {
         throw Exception("Usuario no encontrado. Regístrate primero.");
       }

       // 2. SI EXISTE, LO MARCAMOS COMO ACTIVO
       await prefs.setString('current_active_email', email);
       await storage.saveToken("fake-token-$email");

       // Reconstruimos el usuario para devolverlo
       final profileMap = jsonDecode(userJson);
       final user = UserModel.fromJson(profileMap); // Asegúrate que UserModel tenga fromJson o créalo manual

       return AuthResponseModel(
         user: user, 
         accessToken: "fake-token-$email"
       );
    }
    
    // Lógica real...
    final response = await datasource.login(email: email, password: password);
    await storage.saveToken(response.accessToken);
    return response;
  }
  @override
  Future<void> logout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('my_profile_data');
    //await apiService.post('/auth/logout');
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