import '../../../auth/infrastructure/models/user_model.dart';

abstract class UserDatasource {
  Future<List<UserModel>> getAllUsers();
}