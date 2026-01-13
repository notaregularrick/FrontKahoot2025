import '../../../auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
}