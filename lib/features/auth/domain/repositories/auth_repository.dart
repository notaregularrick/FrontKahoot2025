import '../../infraestructure/models/auth_response_model.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<UserEntity?> register({
    required String name,
    required String email,
    required String password,
    required String username, 
    required String userType,
  });

  Future<AuthResponseModel> login({required String username, required String password});

  Future<AuthResponseModel> checkAuthStatus();

  Future<void> logout();

  Future<void> requestPasswordReset(String email);

  Future<void> confirmPasswordReset(String resetToken, String newPassword);

}