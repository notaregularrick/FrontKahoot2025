import '../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;
  final String? token;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserEntity? user,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      errorMessage: null,
      user: null,
      token: null,
    );
  }
}