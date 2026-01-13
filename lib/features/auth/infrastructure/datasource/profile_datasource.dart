import 'package:dio/dio.dart';
import '../models/profile_model.dart';

class ProfileDatasource {

  final Dio dio;
  ProfileDatasource(this.dio);

  /// PATCH /profile
  Future<ProfileModel> updateProfile(Map<String, dynamic> fields) async {
    const simulate = true;

    if (simulate) {
      // Simulamos la actualización del perfil
      final updatedProfile = ProfileModel(
        id: fields['id'] ?? "temp-id",
        name: fields['name'] ?? "Nombre simulado",
        email: fields['email'] ?? "email@simulado.com",
        avatarUrl: "https://i.pravatar.cc/150",
        description: fields['description'] ?? "Descripción simulada",
        userType: "Básico",
        gameStreak: 0,
        theme: "Día",
        language: "Español",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Devolvemos el perfil simulado
      return updatedProfile;
    }

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
