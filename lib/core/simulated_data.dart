// lib/core/simulated_data.dart

import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/infrastructure/models/profile_model.dart';
import '../features/auth/infrastructure/models/user_model.dart';

// --- BASE DE DATOS SIMULADA (RAM) ---
// Al ser globales, ambos repositorios accederán a la misma información.

UserModel? dbUser;          // Aquí se guarda el usuario registrado
ProfileModel? dbProfile;    // Aquí se guarda el perfil registrado
String? dbToken;            // Aquí se guarda el token