import 'package:dio/dio.dart';
import '../models/profile_model.dart';
import 'profile_datasource.dart';

class ProfileDatasourceImpl implements ProfileDatasource  {

  final Dio dio;
  ProfileDatasourceImpl(this.dio);

  @override
  Future<ProfileModel> getUserProfile() async {
    try {
      final response = await dio.get('/user/profile/');
      
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Sesión expirada');
      }
      throw Exception('Error al cargar el perfil: $e');
    }
  }

  @override
  Future<ProfileModel> getUserProfileById(String id) async {
    try {
      final response = await dio.get('/user/profile/id/$id');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Usuario no encontrado');
        }
      }
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  @override
  Future<ProfileModel> getUserProfileByUsername(String username) async {
    try {
      final response = await dio.get('/user/profile/username/$username');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      }
      throw Exception('Error al buscar usuario: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> fields) async {
    try {
      final response = await dio.patch('/user/profile/', data: fields);
      
      final userData = response.data['user'] ?? response.data;
      return ProfileModel.fromJson(userData);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
           final msg = e.response?.data['message'];
           throw Exception(msg ?? 'Datos incorrectos para actualizar perfil');
        }
      }
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dio.patch('/user/profile/', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': newPassword,
      });
    } catch (e) {
      if (e is DioException) {
         if (e.response?.statusCode == 400) {
            final msg = e.response?.data['message'];
            throw Exception(msg ?? 'Error al cambiar contraseña');
         }
      }
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  
}
