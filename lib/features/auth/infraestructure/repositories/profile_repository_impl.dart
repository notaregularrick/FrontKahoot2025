import '../../../../core/services/api_service.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasource/profile_datasource.dart';
import '../models/profile_model.dart';

// IMPORTA LA MISMA BASE DE DATOS SIMULADA
import '../../../../core/simulated_data.dart'; 

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;
  final ApiService apiService;
  
  ProfileRepositoryImpl(this.datasource, this.apiService);

  @override
  Future<ProfileModel> getUserProfile() async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 1. LEEMOS DE LA DB COMPARTIDA
      // Si dbProfile es null, significa que no te has registrado o logueado en esta sesión
      if (dbProfile == null) {
         // Fallback de emergencia solo si no hay datos
         return ProfileModel(
            id: "guest", name: "Invitado", email: "guest@test.com", 
            avatarUrl: "", description: "", userType: "Guest", 
            gameStreak: 0, theme: "Día", language: "ES", 
            createdAt: DateTime.now(), updatedAt: DateTime.now()
         );
      }
      
      // ¡Aquí devolvemos exactamente lo que creaste en el registro!
      return dbProfile!;
    }

    try {
      final response = await apiService.get('/profile');
      return ProfileModel.fromJson(response.data); 
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> fields) async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 500));

      final current = dbProfile; // Leemos el actual

      // ACTUALIZAMOS LA DB COMPARTIDA
      dbProfile = ProfileModel(
        id: current?.id ?? "temp-id",
        // Si viene un nombre nuevo, lo usamos. Si no, mantenemos el viejo (dbProfile)
        name: fields['name'] ?? current?.name ?? "Usuario",
        email: fields['email'] ?? current?.email ?? "email@test.com",
        description: fields['description'] ?? current?.description ?? "",
        
        avatarUrl: current?.avatarUrl ?? "",
        userType: current?.userType ?? "Básico",
        gameStreak: current?.gameStreak ?? 0,
        theme: current?.theme ?? "Día",
        language: current?.language ?? "Español",
        createdAt: current?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sincronizamos también el usuario básico por si acaso
      if (dbUser != null) {
          dbUser = dbUser!.copyWith(
              name: dbProfile!.name, 
              email: dbProfile!.email
          );
      }

      return dbProfile!.toEntity();
    }

    final model = await datasource.updateProfile(fields);
    return model.toEntity();
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(seconds: 1));
      // Aquí podrías validar que currentPassword coincida con algo, 
      // pero para simular éxito basta con el delay.
      return;
    }

    try {
      await datasource.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: ${e.toString()}');
    }
  }
}