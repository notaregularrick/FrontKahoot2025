import '../../infraestructure/models/auth_response_model.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  //esto registra un usuario y devuelve la entidad que se creo
  Future<UserEntity> register({
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

}