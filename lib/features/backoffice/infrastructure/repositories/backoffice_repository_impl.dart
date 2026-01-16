import '../../domain/entities/backoffice_user.dart';
import '../../domain/repositories/backoffice_repository.dart';
import '../datasource/backoffice_datasource.dart';

class BackofficeRepositoryImpl implements BackofficeRepository {
  final BackofficeDatasource datasource;

  BackofficeRepositoryImpl(this.datasource);

  @override
  Future<BackofficeResponseEntity> getUsers({
    String? name,
    String? userId,
    int page = 1,
    int limit = 20,
    String orderBy = 'createdAt',
    String order = 'asc',
  }) async {
    return await datasource.getUsers(
      name: name,
      userId: userId,
      page: page,
      limit: limit,
      orderBy: orderBy,
      order: order,
    );
  }

  @override
  Future<BackofficeUserEntity> blockUser(String userId) async {
    // El modelo que retorna el datasource es compatible con la entidad
    return await datasource.blockUser(userId);
  }

  @override
  Future<BackofficeUserEntity> unblockUser(String userId) async {
    return await datasource.unblockUser(userId);
  }

  @override
  Future<BackofficeUserEntity> giveAdmin(String userId) async {
    return await datasource.giveAdmin(userId);
  }

  @override
  Future<BackofficeUserEntity> removeAdmin(String userId) async {
    return await datasource.removeAdmin(userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await datasource.deleteUser(userId);
  }
}