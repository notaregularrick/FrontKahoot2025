import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/secure_storage_provider.dart';
import '../services/secure_storage_service.dart'; // Verifica esta ruta
import '../providers/backend_provider.dart'; // <--- IMPORTANTE: Importar el provider del backend

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Dio get dio => _dio;

  // Configuración de interceptores (Token)
  void setUpInterceptors(SecureStorageService storage) {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) => handler.next(response),
      onError: (error, handler) => handler.next(error),
    ));

    // Log para ver qué URL está usando realmente en la consola
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}

// --- EL PROVIDER QUE CONECTA TODO ---
final apiServiceProvider = Provider<ApiService>((ref) {
  // 1. ESCUCHAMOS QUÉ BACKEND ESTÁ SELECCIONADO
  // Si esto cambia (Back1 -> Back2), este provider se reconstruye con la nueva URL.
  final backendType = ref.watch(backendProvider); 
  
  // 2. OBTENEMOS EL STORAGE
  final storage = ref.read(secureStorageProvider);

  // 3. CONFIGURAMOS DIO CON LA URL DEL BACKEND SELECCIONADO
  print("API Service configurado con URL: ${backendType.url}"); // <--- Debug en consola

  final options = BaseOptions(
    baseUrl: backendType.url, // <--- AQUÍ ESTÁ LA MAGIA
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);
  final apiService = ApiService(dio);
  
  // Configuramos interceptores pasando el storage directamente
  apiService.setUpInterceptors(storage);

  return apiService;
});