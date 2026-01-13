import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final SecureStorageService storage;

  AuthInterceptor(this.ref, this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Recuperamos token desde secure storage (opción segura)
    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      // ignore: avoid_print
      print('[auth_interceptor] bearerPresent=true ${options.method} ${options.path}');
    } else {
      // ignore: avoid_print
      print('[auth_interceptor] bearerPresent=false ${options.method} ${options.path}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si backend responde 401 → el token expiró o es inválido
    if (err.response?.statusCode == 401) {
      // Ejecutamos logout automático
      ref.read(authNotifierProvider.notifier).logout();
    }

    return handler.next(err);
  }
}
