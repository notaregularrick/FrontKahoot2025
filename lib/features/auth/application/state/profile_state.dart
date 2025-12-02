import '../../domain/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? errorMessage;

  // Constructor
  ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  // Método copyWith para actualizar solo ciertos valores del estado
  ProfileState copyWith({
    bool? isLoading,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Estado inicial vacío
  static ProfileState initial() {
    return ProfileState(
      isLoading: false,
      profile: null,
      errorMessage: null,
    );
  }
}
