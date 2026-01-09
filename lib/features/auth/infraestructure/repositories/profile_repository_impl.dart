// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANTE
// import '../../../../core/services/api_service.dart';
// import '../../domain/repositories/profile_repository.dart';
// import '../../domain/entities/profile_entity.dart';
// import '../datasource/profile_datasource.dart';
// import '../models/profile_model.dart';

// class ProfileRepositoryImpl implements ProfileRepository {
//   final ProfileDatasource datasource;
//   final ApiService apiService;

//   ProfileRepositoryImpl(this.datasource, this.apiService);

//   @override
//   Future<ProfileModel> getUserProfile() async {
//     const simulate = true;

//     if (simulate) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       final prefs = await SharedPreferences.getInstance();

//       // 1. Buscamos quién está logueado (el email que guardó AuthRepository)
//       final currentEmail = prefs.getString('current_active_email');

//       // Si no hay email activo, devolvemos el Invitado
//       if (currentEmail == null) {
//         return ProfileModel(
//           id: "guest",
//           name: "Invitado",
//           email: "guest@app.com",
//           avatarUrl: "",
//           description: "Inicia sesión para ver tus datos",
//           userType: "Guest",
//           gameStreak: 0,
//           theme: "Día",
//           language: "ES",
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//       }

//       // 2. Cargamos el perfil de ese email específico usando la misma clave que en el Registro
//       final userJson = prefs.getString('profile_$currentEmail');

//       if (userJson != null) {
//         final Map<String, dynamic> data = jsonDecode(userJson);

//         // Importante: Asegúrate de que ProfileModel.fromJson convierta bien las fechas
//         // (Si usaste el copy-paste anterior para UserModel, verifica que ProfileModel
//         // también use DateTime.parse en su fromJson).
//         return ProfileModel.fromJson(data);
//       }

//       throw Exception("Perfil no encontrado en disco local");
//     }

//     // Lógica real con API
//     try {
//       final response = await apiService.get('/profile');
//       return ProfileModel.fromJson(response.data);
//     } catch (e) {
//       throw Exception('Error al obtener perfil: $e');
//     }
//   }

//   @override
//   Future<ProfileEntity> updateProfile(Map<String, dynamic> fields) async {
//     const simulate = true;

//     if (simulate) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       final prefs = await SharedPreferences.getInstance();

//       // 1. Obtener usuario actual
//       final currentEmail = prefs.getString('current_active_email');
//       if (currentEmail == null) throw Exception("No hay sesión activa");

//       final userJson = prefs.getString('profile_$currentEmail');
//       if (userJson == null) throw Exception("Datos corruptos");

//       // 2. Mezclar datos viejos con los nuevos
//       final Map<String, dynamic> currentData = jsonDecode(userJson);

//       final updatedProfile = ProfileModel(
//         id: currentData['id'],
//         // Si fields['name'] existe úsalo, si no usa el viejo
//         name: fields['name'] ?? currentData['name'],
//         email: currentData['email'],
//         description: fields['description'] ?? currentData['description'],
//         avatarUrl: currentData['avatarUrl'],
//         userType: currentData['userType'],
//         gameStreak: currentData['gameStreak'],
//         theme: currentData['theme'],
//         language: currentData['language'],
//         // Parseamos las fechas viejas para no perderlas
//         createdAt: DateTime.parse(currentData['createdAt']),
//         updatedAt: DateTime.now(),
//       );

//       // 3. Guardar de nuevo (¡Sin perder la contraseña!)
//       Map<String, dynamic> dataToSave = updatedProfile.toJson();
//       dataToSave['password'] =
//           currentData['password']; // Recuperamos pass vieja

//       await prefs.setString('profile_$currentEmail', jsonEncode(dataToSave));

//       return updatedProfile.toEntity();
//     }

//     final model = await datasource.updateProfile(fields);
//     return model.toEntity();
//   }

//   @override
//   Future<void> changePassword(
//     String currentPassword,
//     String newPassword,
//   ) async {
//     const simulate = true;
//     if (simulate) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       // Aquí podrías implementar la lógica de leer SharedPreferences,
//       // verificar password vieja y guardar la nueva.
//       return;
//     }
//     await datasource.changePassword(currentPassword, newPassword);
//   }
// }

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/api_service.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasource/profile_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;
  final ApiService apiService;

  ProfileRepositoryImpl(this.datasource, this.apiService);

  @override
  Future<ProfileModel> getUserProfile() async {
    const simulate = true;

    if (simulate) {
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();

      // 1. AVERIGUAR QUIÉN ESTÁ CONECTADO
      final String? activeEmail = prefs.getString('current_active_email');

      if (activeEmail == null) {
        throw Exception("No hay sesión activa");
      }

      // 2. BUSCAR LA CAJA ESPECÍFICA DE ESE EMAIL
      final String? profileString = prefs.getString('profile_$activeEmail');

      if (profileString != null) {
        Map<String, dynamic> jsonMap = jsonDecode(profileString);
        return ProfileModel.fromJson(jsonMap);
      }

      // Fallback
      return ProfileModel(
        id: "error",
        name: "Error",
        email: "error",
        avatarUrl: "",
        description: "",
        userType: "",
        gameStreak: 0,
        theme: "",
        language: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
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
      final prefs = await SharedPreferences.getInstance();

      // 1. OBTENER EMAIL ACTIVO
      final activeEmail = prefs.getString('current_active_email');
      if (activeEmail == null) throw Exception("No login");

      // 2. LEER PERFIL VIEJO
      final String? currentString = prefs.getString('profile_$activeEmail');
      // ... decodificar current ... (igual que antes)
      final current = ProfileModel.fromJson(jsonDecode(currentString!));

      // 3. CREAR NUEVO
      final updated = ProfileModel(
        id: current.id,
        name: fields['name'] ?? current.name,
        email:
            fields['email'] ??
            current.email, // OJO: Si cambia el email, habría que mover la caja
        description: fields['description'] ?? current.description,
        // ... resto de campos ...
        avatarUrl: current.avatarUrl,
        userType: current.userType,
        gameStreak: current.gameStreak,
        theme: current.theme,
        language: current.language,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );

      // 4. GUARDAR EN LA MISMA CAJA
      await prefs.setString(
        'profile_$activeEmail',
        jsonEncode(updated.toJson()),
      );

      return updated.toEntity();
    }

    final model = await datasource.updateProfile(fields);
    return model.toEntity();
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
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