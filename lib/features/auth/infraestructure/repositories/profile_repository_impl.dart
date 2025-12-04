import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasource/profile_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  final ProfileDatasource datasource;
  ProfileRepositoryImpl(this.datasource);

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields) async {
    const simulate = true;  // Simulación activada

    if (simulate) {
      // Simulamos los cambios que se harían en el backend
      final updatedProfile = ProfileModel(
        id: fields['id'] ?? "temp-id",
        name: fields['name'] ?? "Nombre simulado",
        email: fields['email'] ?? "email@simulado.com",
        avatarUrl: "https://i.pravatar.cc/150",  // URL de imagen de avatar
        description: fields['description'] ?? "Descripción simulada",
        userType: "Básico",  // Ejemplo de tipo de usuario
        gameStreak: 0,       // Ejemplo de racha de juego
        theme: "Día",        // Tema de la aplicación
        language: "Español", // Idioma
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Aquí devolvemos el modelo simulado
      return updatedProfile.toEntity();  // Convertimos el ProfileModel a ProfileEntity
    }


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
