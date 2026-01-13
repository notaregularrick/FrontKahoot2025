import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/category.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/categories/domain/categories_repository.dart';

class CategoriesRepositoryImpl implements ICategoriesRepository {
  final Dio _dio;

  CategoriesRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Category>> getCategories() async {
    try {
      print('[CATEGORIES] Obteniendo categorías desde /explore/categories');
      
      final response = await _dio.get('/explore/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final categories = data
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
        print('[CATEGORIES] ${categories.length} categorías obtenidas');
        return categories;
      } else {
        print('[CATEGORIES] Error: código ${response.statusCode}');
        throw AppException(
          message: 'Error al obtener las categorías',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('[CATEGORIES] DioException: ${e.type} - ${e.message}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final serverData = e.response?.data?.toString() ?? 'Sin datos';
        
        String message;
        if (statusCode == 404) {
          message = 'Endpoint /explore/categories no encontrado';
        } else if (statusCode == 401) {
          message = 'No autorizado - Token inválido o expirado';
        } else if (statusCode == 500) {
          message = 'Error interno del servidor al recuperar categorías';
        } else {
          message = 'Error del servidor (código: $statusCode)';
        }
        
        throw AppException(
          message: message,
          statusCode: statusCode,
          error: serverData,
        );
      } else {
        throw AppException(
          message: 'Error de conexión al obtener las categorías',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      print('[CATEGORIES] Error inesperado: $e');
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado al obtener las categorías',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}

