import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasource/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  final ProfileDatasource datasource;
  ProfileRepositoryImpl(this.datasource);

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields) async {
    final model = await datasource.updateProfile(fields);
    return model.toEntity();
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await datasource.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: ${e.toString()}');
    }
  }
}
