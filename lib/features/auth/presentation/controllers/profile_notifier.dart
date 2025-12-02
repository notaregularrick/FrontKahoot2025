import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/profile_repository.dart';
import '../../application/state/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {

  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileState.initial());

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true);

    try {
      final updated = await repository.updateProfile(fields);
      state = state.copyWith(profile: updated, isLoading: false);

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
