import '../entities/backoffice_user.dart';

abstract class BackofficeRepository {
  Future<BackofficeResponseEntity> getUsers({
    String? name,
    String? userId,
    int page = 1,
    int limit = 20,
    String orderBy = 'createdAt',
    String order = 'asc',
  });

  Future<BackofficeUserEntity> blockUser(String userId);

  Future<BackofficeUserEntity> unblockUser(String userId);

  Future<BackofficeUserEntity> giveAdmin(String userId);

  Future<BackofficeUserEntity> removeAdmin(String userId);

  Future<void> deleteUser(String userId);
}