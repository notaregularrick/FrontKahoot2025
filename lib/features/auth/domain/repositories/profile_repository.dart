//import '../../infrastructure/models/profile_model.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields);

  Future<void> changePassword(String currentPassword, String newPassword);

   Future<ProfileEntity> getUserProfile();
   Future<ProfileEntity> getUserProfileById(String id);
   Future<ProfileEntity> getUserProfileByUsername(String username);
}
