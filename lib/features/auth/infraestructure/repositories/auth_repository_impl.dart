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

class AuthRepositoryImpl implements AuthRepository{

  final AuthDatasource datasource;
  final ApiService apiService;
 final SecureStorageService storage;

  AuthRepositoryImpl(this.datasource, this.apiService, this.storage);

 
  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    
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