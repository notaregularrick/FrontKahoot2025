import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/profile_repository.dart';
import '../../application/state/profile_state.dart';
import '../../infraestructure/models/profile_model.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {

  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileState.initial());

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true);

    try {
      const simulate = true; // Simulamos el cambio si está activado

      if (simulate) {
        // Simulamos la actualización del perfil
        final updatedProfile = ProfileModel(
        id: state.profile?.id ?? 'new-id',
        name: fields['name'],
        email: fields['email'],
        description: fields['description'] ?? '',
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
        // En caso de que no se esté simulando, seguimos con el flujo normal
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
    state = state.copyWith(isLoading: true);

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
