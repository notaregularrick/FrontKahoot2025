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
      // Aquí puedes manejar errores específicos de Dio (401, 400)
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    // Mantén tu lógica de registro anterior aquí
    // ...
    throw UnimplementedError(); 
  }

  // NUEVO: Implementación de Check Status
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
