import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasource/profile_datasource.dart'; 

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;

  ProfileRepositoryImpl(this.datasource);

  @override
  Future<ProfileEntity> getUserProfile() async {
    final model = await datasource.getUserProfile();
    return model.toEntity();
  }

  @override
  Future<ProfileEntity> getUserProfileById(String id) async {
    final model = await datasource.getUserProfileById(id);
    return model.toEntity();
  }

  @override
  Future<ProfileEntity> getUserProfileByUsername(String username) async {
    final model = await datasource.getUserProfileByUsername(username);
    return model.toEntity();
  }

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields) async {
    final model = await datasource.updateProfile(fields);
    return model.toEntity();
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await datasource.changePassword(currentPassword, newPassword);
  }
}