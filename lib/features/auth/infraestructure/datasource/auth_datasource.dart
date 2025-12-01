import 'package:frontkahoot2526/features/auth/infraestructure/models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthDatasource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
}