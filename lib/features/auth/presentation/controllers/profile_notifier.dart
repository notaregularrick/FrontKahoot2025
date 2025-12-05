import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/profile_repository.dart';
import '../../application/state/profile_state.dart';
import '../../infraestructure/models/profile_model.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {

  final ProfileRepository repository;

  // Constructor
  ProfileNotifier(this.repository) : super(ProfileState.initial()) {
    // OPCIONAL: Si quieres que cargue apenas se crea el provider, descomenta esto:
    // getUserProfile(); 
  }

  // --- 1. ESTO ES LO QUE FALTABA: MÉTODO PARA OBTENER DATOS ---
  Future<void> getUserProfile() async {
    // Evitamos recargar si ya está cargando
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Obtenemos el MODELO desde el repositorio
      final profileModel = await repository.getUserProfile();

      state = state.copyWith(
        isLoading: false,
        // 2. CORRECCIÓN: Convertimos el modelo a ENTIDAD
        profile: profileModel.toEntity(), 
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  // -----------------------------------------------------------

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      const simulate = true; 

      if (simulate) {
        // Simulamos la actualización del perfil
        final updatedProfile = ProfileModel(
          id: state.profile?.id ?? 'temp-id', // Ajustado para evitar nulos
          name: fields['name'] ?? state.profile?.name ?? '',
          email: fields['email'] ?? state.profile?.email ?? '',
          description: fields['description'] ?? state.profile?.description ?? '',
          userType: state.profile?.userType ?? 'Básico',
          avatarUrl: state.profile?.avatarUrl ?? 'https://i.pravatar.cc/150',
          theme: state.profile?.theme ?? 'Día',
          language: state.profile?.language ?? 'Español',
          gameStreak: state.profile?.gameStreak ?? 0,
          createdAt: state.profile?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Actualizamos el estado con el perfil simulado
        state = state.copyWith(profile: updatedProfile.toEntity(), isLoading: false);
      } else {
        // Flujo real
        final updated = await repository.updateProfile(fields);
        state = state.copyWith(profile: updated, isLoading: false);
      }

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repository.changePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}