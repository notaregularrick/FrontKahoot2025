//import 'package:dio/dio.dart';

import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';
//import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

// --- SIMULACIÓN SIN API -------------------
UserModel? _mockUser;         // guarda el usuario
String? _mockToken;           // guarda un token falso
ProfileModel? _mockProfile;   // guarda el perfil
// ------------------------------------------

class AuthRepositoryImpl implements AuthRepository{

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
    // Creamos un usuario simulado
    _mockUser = UserModel(
      id: "temp-id",
      name: name,
      email: email,
      userType: 'default',
      createdAt: DateTime.now()
    );

    // Guardar token temporalmente
    _mockToken = "fake-token-123";

    // Simulamos un perfil (puede ser más completo)
    _mockProfile = ProfileModel(
      id: "tempo-id",
      name: name,
      email: email,
      avatarUrl: "https://i.pravatar.cc/150",
      description: "Nuevo usuario de prueba",
      userType: "Básico",
      gameStreak: 0,
      theme: "Día",
      language: "Español",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now()

    );

    // Opcional: guardarlo en secure storage para simular sesión verdadera
    await storage.saveToken(_mockToken);

    return _mockUser?.toEntity();
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
    
    final response = await datasource.login(
      email:email,
      password:password,
    );

    //await storage.saveToken(response.accessToken);

    return response;
  }

  @override
  Future<void> logout() async {
    await apiService.post('/auth/logout');
    // El backend da 204, no hay body
  }

  // Método para restablecimiento de contraseña
  @override
Future<void> requestPasswordReset(String email) async {
  const simulate = true;

  if(simulate){
    await Future.delayed(const Duration(seconds: 1)); // simula espera
    return;
  }

  try {
    // Enviar la solicitud al backend
    await apiService.post('/auth/password-reset/request', data: {
      'email': email,
    });
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      throw Exception('Formato de email inválido.');
    } else {
      throw Exception('Error al intentar restablecer la contraseña: ${e.message}');
    }
  } catch (e) {
    throw Exception('Error al intentar restablecer la contraseña: ${e.toString()}');
  }
}

@override
  Future<void> confirmPasswordReset(String resetToken, String newPassword) async {
    try {
      // Enviar solicitud de actualización de contraseña
      await apiService.post('/auth/password-reset/confirm', data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Error al intentar establecer la nueva contraseña: ${e.toString()}');
    }
  }

  @override
  Future<ProfileModel> getUserProfile() async {
    try {
      final response = await apiService.get('/profile');
      return ProfileModel.fromJson(response.data); // Asumimos que la respuesta es un JSON
    } catch (e) {
      throw Exception('Error al obtener el perfil del usuario: ${e.toString()}');
    }
  }

}