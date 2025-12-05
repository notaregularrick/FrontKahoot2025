import '../../infraestructure/models/auth_response_model.dart';
import '../../infraestructure/models/profile_model.dart';
//import '../entities/profile_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  //esto registra un usuario y devuelve la entidad que se creo
  Future<UserEntity?> register({
                                required String name,
                                required String email,
                                required String password,
  });

  //aqui se autentica y devolvemos el token de acceso
  Future<AuthResponseModel> login({
                        required String email,
                        required String password,
  });

  Future<void> logout();

  Future<void> requestPasswordReset(String email);

  Future<void> confirmPasswordReset(String resetToken, String newPassword);

  //Future<ProfileModel> getUserProfile();

}