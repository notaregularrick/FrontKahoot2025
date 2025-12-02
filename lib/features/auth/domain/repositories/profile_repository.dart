import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields);

  Future<void> changePassword(String currentPassword, String newPassword);
}
