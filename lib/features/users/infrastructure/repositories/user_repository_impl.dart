import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<List<UserEntity>> getAllUsers() async {

    final models = await datasource.getAllUsers();
    
    return models.map((model) => model.toEntity()).toList();
  }
}