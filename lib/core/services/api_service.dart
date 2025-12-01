import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontkahoot2526/features/auth/presentation/providers/auth_providers.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Configuración global para Dio
  void setUpInterceptors(Ref ref) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Aquí conseguimos el token desde el estado de auth
        final token = ref.read(authNotifierProvider).token;

        // Si el token existe, lo agregamos a la cabecera
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  // Método GET como ejemplo
  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } catch (e) {
      rethrow; // Aquí puedes agregar el manejo de errores
    }
  }

  // Otros métodos para POST, PUT, DELETE, etc., siguiendo el mismo patrón
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = Dio(); // Crear instancia de Dio

  final apiService = ApiService(dio);
  apiService.setUpInterceptors(ref); // Configura el interceptor

  return apiService;
});
