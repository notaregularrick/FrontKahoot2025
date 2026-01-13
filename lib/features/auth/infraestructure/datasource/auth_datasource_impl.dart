import 'package:dio/dio.dart';
import 'auth_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final Dio dio;

  AuthDatasourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login({required String username, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        // Manejo específico para Login
        if (e.response?.statusCode == 401) {
          throw Exception('Usuario o contraseña incorrectos.');
        }
        final msg = e.response?.data['message'];
        if (msg != null) throw Exception(msg);
      }
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String username,
    required String userType, 
  }) async {
    try {
      final requestData = {
        "email": email,
        "username": username,
        "password": password,
        "name": name,
        "type": userType,
      };

      print("📤 Enviando datos de registro: $requestData");

      final response = await dio.post(
        '/user/register',
        data: requestData,
      );

      final userData = response.data['user'];
      return UserModel.fromJson(userData);

    } catch (e) {
      if (e is DioException) {
        print("🔴 Error del servidor (${e.response?.statusCode}): ${e.response?.data}");

        if (e.response?.statusCode == 400) {
          final serverMsg = e.response?.data['message'];
          if (serverMsg != null) {
            throw Exception(serverMsg);
          }
          throw Exception('Datos inválidos. Verifica que el usuario/email no existan.');
        }
      }
      throw Exception('No se pudo registrar: $e');
    }
  }

  @override
  Future<AuthResponseModel> checkAuthStatus(String token) async {
    try {
      final response = await dio.get(
        '/auth/check-status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Token inválido o expirado');
    }
  }
}
