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
        final dynamic data = response.data;
        List<dynamic> listData;

        if (data is List) {
          // Caso A: El backend devuelve directamente [{}, {}]
          listData = data;
        } else if (data is Map &&
            data.containsKey('data') &&
            data['data'] is List) {
          // Caso B: El backend devuelve { "data": [{}, {}] }
          listData = data['data'];
        } else if (data is Map &&
            data.containsKey('categories') &&
            data['categories'] is List) {
          // CORRECCIÓN: Caso C: { "categories": [{}, {}] } -> Este es el que está llegando
          listData = data['categories'];
        } else {
          print("Formato de categorías desconocido: $data");
          return [];
        }

        final categories = listData
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
