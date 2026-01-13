import 'package:dio/dio.dart';
import 'auth_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final Dio dio;

  AuthDatasourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await dio.post(
        '/user/register',
        data: {
          "email": email,
          "username": username,
          "password": password,
          "name": name,
          "type": "user"
        },
      );

      final userData = response.data['user'];

      return UserModel.fromJson(userData);
    } catch (e) {
      // 1. Capturamos excepciones de Dio (Respuestas 400, 500, etc.)
      if (e is DioException) {
        // 2. Extraemos el mensaje amigable del backend
        // Backend devuelve: { "message": "Invalid user name", ... }
        final serverMessage = e.response?.data['message'];
        
        if (serverMessage != null) {
          // 3. Lanzamos SOLO el mensaje del servidor
          throw Exception(serverMessage); 
        }
      }
      
      // Fallback para otros errores
      throw Exception('Error al registrar usuario. Verifica tu conexión.');
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
