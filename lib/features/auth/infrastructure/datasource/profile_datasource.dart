import '../models/profile_model.dart';

abstract class ProfileDatasource {
  Future<ProfileModel> getUserProfile();
  Future<ProfileModel> getUserProfileById(String id);
  Future<ProfileModel> getUserProfileByUsername(String username); 
  Future<ProfileModel> updateProfile(Map<String, dynamic> fields);
  Future<void> changePassword(String currentPassword, String newPassword);
}