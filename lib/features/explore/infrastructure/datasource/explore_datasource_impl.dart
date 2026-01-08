import 'package:dio/dio.dart';
import '../models/category_model.dart';
import 'explore_datasource.dart';
import '../models/paginated_quizzes_model.dart';

class ExploreDatasourceImpl implements ExploreDatasource {
  // Inyectamos Dio para realizar las peticiones
  final Dio dio;

  ExploreDatasourceImpl(this.dio);

  @override
  Future<PaginatedQuizzesModel> getQuizzes({
    String? searchQuery,
    List<String>? categories,
    int limit = 20,
    int page = 1,
    String? orderBy,
    String? order,
  }) async {
    try {
      // 1. Construimos el mapa de parámetros dinámicamente
      // Solo agregamos al mapa los valores que no sean nulos
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'page': page,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      // Dio maneja listas en query params automáticamente (ej: categories[]=math&categories[]=science)
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

      if (orderBy != null) {
        queryParams['orderBy'] = orderBy;
      }

      if (order != null) {
        queryParams['order'] = order;
      }

      // 2. Hacemos la petición GET
      final response = await dio.get(
        '/explore',
        queryParameters: queryParams,
      );

      // 3. Convertimos el JSON crudo en nuestro Modelo PaginatedQuizzesModel
      return PaginatedQuizzesModel.fromJson(response.data);
      
    } catch (e) {
      // Aquí podrías capturar DioException para errores más específicos (404, 500)
      throw Exception('Error en ExploreDatasource: $e');
    }
  }

  @override
  Future<PaginatedQuizzesModel> getFeaturedQuizzes({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/explore/featured',
        queryParameters: {'limit': limit},
      );
      
      return PaginatedQuizzesModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error en getFeaturedQuizzes: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/explore/categories');
      
      // La respuesta es una lista directa: [ {name: "A"}, {name: "B"} ]
      final List<dynamic> data = response.data as List<dynamic>;
      
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error en getCategories: $e');
    }
  }
}