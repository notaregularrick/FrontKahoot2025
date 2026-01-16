import '../models/backoffice_response_model.dart';

abstract class BackofficeDatasource {
  Future<BackofficeResponseModel> getUsers({
    String? name,
    String? userId,
    int page = 1,
    int limit = 20,
    String orderBy = 'createdAt',
    String order = 'asc',
  });

  Future<BackofficeUserModel> blockUser(String userId);

  Future<BackofficeUserModel> unblockUser(String userId);

  Future<BackofficeUserModel> giveAdmin(String userId);

  Future<BackofficeUserModel> removeAdmin(String userId);

  Future<void> deleteUser(String userId);
}