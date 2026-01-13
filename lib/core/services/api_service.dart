import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/secure_storage_provider.dart';
// Asegúrate de que este import apunte a donde definiste SecureStorageService
import '../services/secure_storage_service.dart'; 
import '../providers/backend_provider.dart'; 

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Dio get dio => _dio;

  // CORRECCIÓN: Recibimos SecureStorageService directamente, NO 'Ref'
  void setUpInterceptors(SecureStorageService storage) {
    _dio.interceptors.clear(); // Limpiamos previos
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Usamos la instancia de storage inyectada directamente
        // Esto evita el error de "ref functions" porque no usamos ref aquí dentro
        final token = await storage.getToken(); 

        if (token != null && token.isNotEmpty) {
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

    // Log para depuración
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

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
  // 1. Escuchamos cambios en la URL del backend
  final backendType = ref.watch(backendProvider);
  
  // 2. Leemos el servicio de almacenamiento UNA VEZ durante la construcción
  final storage = ref.read(secureStorageProvider);

  final options = BaseOptions(
    baseUrl: backendType.url,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options); 
  
  final apiService = ApiService(dio);
  
  // 3. Pasamos el servicio de storage ya resuelto
  apiService.setUpInterceptors(storage); 

  return apiService;
});