import 'package:dio/dio.dart';
import '../models/profile_model.dart';

class ProfileDatasource {

  final Dio dio;
  ProfileDatasource(this.dio);

  /// PATCH /profile
  Future<ProfileModel> updateProfile(Map<String, dynamic> fields) async {
    final response = await dio.patch('/profile', data: fields);

    return ProfileModel.fromJson(response.data);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await dio.patch('/profile/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    if (response.statusCode != 204) {
      throw Exception('Error al cambiar la contraseña');
    }
  }
}
