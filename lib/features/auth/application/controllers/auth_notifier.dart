import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../state/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../notifications/domain/repositories/notifications_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage;
  final NotificationsRepository? notificationsRepository;
  final FcmService fcmService;

  AuthNotifier(
    this.repository,
    this.storage, {
    this.notificationsRepository,
    FcmService? fcmService,
  })  : fcmService = fcmService ?? FcmService.instance,
        super(AuthState.initial());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await repository.login(username: username, password: password);
      
      state = state.copyWith(
        isLoading: false,
        token: response.accessToken,
        user: response.user,
        errorMessage: null,
      );

      // Registrar token FCM después de login exitoso
      _registerDeviceToken();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _registerDeviceToken() async {
    if (notificationsRepository == null) return;

    try {
      final token = await fcmService.getToken();
      if (token != null) {
        await notificationsRepository!.registerDevice(token);
      }
    } catch (e) {
      // No bloqueamos el flujo de login si falla el registro del token
      print('Error al registrar token FCM: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.checkAuthStatus();
      
      state = state.copyWith(
        isLoading: false,
        token: response.accessToken,
        user: response.user,
      );
    } catch (e) {
      state = AuthState.initial();
    }
  }

  Future<void> logout() async {
    // Desregistrar token FCM antes de hacer logout
    await _unregisterDeviceToken();
    
    await repository.logout();
    state = AuthState.initial();
  }

  Future<void> _unregisterDeviceToken() async {
    if (notificationsRepository == null) return;

    try {
      final token = await fcmService.getToken();
      if (token != null) {
        await notificationsRepository!.unregisterDevice(token);
      }
    } catch (e) {
      // No bloqueamos el flujo de logout si falla el desregistro del token
      print('Error al desregistrar token FCM: $e');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String username,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repository.register(
        name: name,
        email: email,
        password: password,
        username: username,
        userType: userType,
      );

      state = state.copyWith(isLoading: false);

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}