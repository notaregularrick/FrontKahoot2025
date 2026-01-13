import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthDatasource {
  Future<AuthResponseModel> login({required String email, required String password});
  
  // ACTUALIZADO: Agregamos username
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String username, 
  });

  Future<AuthResponseModel> checkAuthStatus(String token);
}