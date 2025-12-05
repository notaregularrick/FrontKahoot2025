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

      final newProfile = ProfileModel(
        id: email,
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

      // 1. CONVERTIMOS EL PERFIL A MAPA
      Map<String, dynamic> dataToSave = newProfile.toJson();

      // 2. ¡TRUCO! AGREGAMOS LA CONTRASEÑA AL MAPA ANTES DE GUARDAR
      // (Así la "Base de datos" recuerda tu clave)
      dataToSave['password'] = password;

      // 3. GUARDAMOS TODO EL JSON (Perfil + Password)
      String profileJson = jsonEncode(dataToSave);
      await prefs.setString('profile_$email', profileJson);

      // Guardamos sesión activa
      await prefs.setString('current_active_email', email);
      await storage.saveToken("fake-token-$email");

      return UserModel(
        id: newProfile.id,
        name: newProfile.name,
        email: newProfile.email,
        userType: newProfile.userType,
        createdAt: newProfile.createdAt,
      ).toEntity();
    }

    final userModel = await datasource.register(
      name: name,
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 800));
      final prefs = await SharedPreferences.getInstance();

      // 1. VERIFICAR SI EL EMAIL EXISTE
      if (!prefs.containsKey('profile_$email')) {
        throw Exception("Usuario no encontrado. Verifica el email.");
      }

      // 2. LEER LOS DATOS GUARDADOS
      final userJson = prefs.getString('profile_$email');
      final Map<String, dynamic> storedData = jsonDecode(userJson!);

      // 3. VALIDAR LA CONTRASEÑA
      // Comparamos la pass que escribiste con la que guardamos en el registro
      if (storedData['password'] != password) {
        throw Exception("Contraseña incorrecta.");
      }

      // SI PASA LA VALIDACIÓN, PROCEDEMOS:

      // Marcar como activo
      await prefs.setString('current_active_email', email);
      await storage.saveToken("fake-token-$email");

      // Convertir a modelo de usuario (ignorando el campo password extra que metimos)
      final user = UserModel.fromJson(storedData);

      return AuthResponseModel(user: user, accessToken: "fake-token-$email");
    }

    // Lógica real...
    final response = await datasource.login(email: email, password: password);
    await storage.saveToken(response.accessToken);
    return response;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_active_email');
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
      await apiService.post(
        '/auth/password-reset/request',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Error al solicitar reset: $e');
    }
  }

  @override
  Future<void> confirmPasswordReset(
    String resetToken,
    String newPassword,
  ) async {
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
      print(
        "SIMULACIÓN: Contraseña restablecida exitosamente. Nueva pass: $newPassword",
      );
      return;
    }

    // --- LÓGICA REAL ---
    try {
      await apiService.post(
        '/auth/password-reset/confirm',
        data: {'resetToken': resetToken, 'newPassword': newPassword},
      );
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
